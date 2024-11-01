# retraining_job.py

import os
import boto3
import sagemaker
import pandas as pd
import numpy as np
import joblib
import uuid
import time
from sagemaker import get_execution_role
from dotenv import load_dotenv
from sklearn.metrics import r2_score
from sklearn.model_selection import train_test_split
from sagemaker.sklearn.estimator import SKLearn

# Import custom modules
from load_data import load_data
from transform_data import split_data, preprocess_df, feature_selection
from save_model_to_s3 import save_model_to_s3
from deploy_model_endpoint import deploy_model
from finalize_and_save_model import finalize_and_save_model
from delete_sagemaker_endpoint import delete_sagemaker_endpoint

# PyCaret imports
import pycaret
from pycaret.regression import *
from pycaret.classification import *
import shap

# Load environment variables
load_dotenv(".env")
role = get_execution_role()

# Environment variables
data_location_s3 = os.getenv("data_location_s3")
algorithm_choice = os.getenv("algorithm_choice")
target = os.getenv("target")
endpoint_name = os.getenv("endpoint_name")
model_name = os.getenv("model_name")
data_location = f"s3://{data_location_s3}"
instance_type = os.getenv("instance_type")
model_instance_count = int(os.getenv("model_instance_count"))
image_uri = os.getenv("ecr_repo_uri")
tuning_metric = os.getenv("tuning_metric")
existing_model_s3_uri = os.getenv('existing_model_s3_uri')  # S3 URI of the existing model

# Initialize variables
bucket = data_location_s3.split('/')[0]  # Assuming data_location_s3 is in the format 'bucket-name/prefix'
prefix = '/'.join(data_location_s3.split('/')[1:])
region = boto3.Session().region_name
session = sagemaker.Session()

# Load data
FILE_DATA = load_data(data_location)
print(FILE_DATA.head())
print(f"Total records: {len(FILE_DATA)}")

# Preprocess data
FILE_DATA = preprocess_df(FILE_DATA)
FILE_DATA = feature_selection(FILE_DATA, target)

# Split data
train_and_val_data, test_data = split_data(FILE_DATA, shuffle=True)
train_data, validation_data = split_data(train_and_val_data, shuffle=True)

# Save validation data to S3 for model evaluation
validation_data.to_csv('validation_data.csv', index=False)
s3_client = boto3.client('s3')
validation_s3_key = f'{prefix}/validation_data.csv'
s3_client.upload_file('validation_data.csv', bucket, validation_s3_key)
validation_data_s3_uri = f's3://{bucket}/{validation_s3_key}'

# Function to evaluate model and calculate R² score
def evaluate_model(model, data):
    X = data.drop(columns=[target])
    y = data[target]
    predictions = model.predict(X)
    r2 = r2_score(y, predictions)
    return r2

# Load existing model from S3
def load_existing_model(s3_uri):
    s3 = boto3.client('s3')
    bucket_name = s3_uri.split('/')[2]
    key = '/'.join(s3_uri.split('/')[3:])
    model_file = 'existing_model.pkl'
    s3.download_file(bucket_name, key, model_file)
    model = joblib.load(model_file)
    return model

# Evaluate current model
current_model = load_existing_model(existing_model_s3_uri)
current_r2 = evaluate_model(current_model, validation_data)
print(f"Current model R² score: {current_r2}")

# Check if retraining is needed
if current_r2 < 0.6:
    print("Current R² score is less than 60%. Retraining the model...")
    
    # Set up PyCaret environment
    if algorithm_choice.lower() == "classification":
        clf = setup(data=train_data, target=target, silent=True, session_id=123)
        bestModel = compare_models()
        # Evaluate model: Display UI analyzing Hyperparameters, Confusion Matrix, Class Report, etc.
        evaluate_model(bestModel, validation_data)
        # Finalize model
        final_model = finalize_and_save_model(algorithm_choice, bestModel, model_name)
    elif algorithm_choice.lower() == "regression":
        reg = setup(data=train_data, target=target, silent=True, session_id=123)
        bestModel = compare_models()
        # Evaluate model: Display UI analyzing Hyperparameters, Residuals Plot, etc.
        evaluate_model(bestModel, validation_data)
        # Finalize model
        final_model = finalize_and_save_model(algorithm_choice, bestModel, model_name)
    else:
        raise ValueError("Invalid algorithm choice. Please choose 'classification' or 'regression'.")

    # Evaluate new model
    new_r2 = evaluate_model(final_model, validation_data)
    print(f"New model R² score: {new_r2}")

    # Compare R² scores
    if new_r2 > current_r2:
        print("New model outperforms the current model. Deploying new model...")
        # Save new model to local file
        joblib.dump(final_model, f'{model_name}-model.pkl')
        # Upload model to S3
        save_model_to_s3(f'{model_name}-model.pkl', f'{model_name}-model.pkl')
        # Deploy model to SageMaker endpoint
        deploy_model(model_name, instance_type, endpoint_name, role, model_instance_count, image_uri)
        print("New model deployed successfully.")
    else:
        print("New model does not outperform the current model. Keeping the existing model.")
else:
    print("Current R² score is above 60%. No retraining needed.")

# Clean up local files if necessary
os.remove('validation_data.csv')
if os.path.exists(f'{model_name}-model.pkl'):
    os.remove(f'{model_name}-model.pkl')
if os.path.exists('existing_model.pkl'):
    os.remove('existing_model.pkl')
