#!/usr/bin/env python

# Import the necessary libraries
import json
from pycaret.regression import load_model
import flask
from flask import Flask, request
import pandas as pd
import os
import logging

logging.basicConfig(level=logging.DEBUG)

# Instantiate Flask app
app = Flask(__name__)

MODEL_NAME = os.getenv("MODEL_NAME")
MODEL_TYPE = os.getenv("MODEL_TYPE")

# Define the model path
# When you configure the model, you will need to specify the S3 location of
# your model artifacts.
# Sagemaker will automatically download, decompress and store the model's
# weights in the /opt/ml/model folder.
MODEL_PATH = f"/opt/ml/model/{MODEL_NAME}"
logging.info(MODEL_PATH)
logging.info(MODEL_TYPE)

# Load the model from the specified path
model = load_model(MODEL_PATH)


@app.route("/ping", methods=["GET"])
def ping():
    return flask.Response(response="\n", status=200,
                          mimetype="application/json")


# Define an endpoint for making predictions
@app.route("/invocations", methods=["POST"])
def predict():
    # Get data from the POST request
    data = request.get_data().decode("utf-8")

    # Convert the data into a Pandas DataFrame
    df = pd.read_json(data, orient="split")
    logging.info(df)

    # Make predictions using the loaded model
    if MODEL_TYPE == "classification":
        prediction = model.predict_proba(df)
    else:
        prediction = model.predict(df)
    logging.debug(f"Prediction: {prediction}")

    # Return the prediction results as JSON
    return json.dumps(prediction.tolist())


if __name__ == "__main__":
    app.run()
