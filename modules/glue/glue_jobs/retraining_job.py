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
# from load_data import load_data
# from transform_data import split_data, preprocess_df, feature_selection
# from save_model_to_s3 import save_model_to_s3
# from deploy_model_endpoint import deploy_model
# from finalize_and_save_model import finalize_and_save_model
# from delete_sagemaker_endpoint import delete_sagemaker_endpoint

# PyCaret imports
import pycaret
from pycaret.regression import *
from pycaret.classification import *
from ydata_profiling import ProfileReport
import shap
