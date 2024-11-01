from setuptools import setup

setup(
    name="mlops_dependencies_module",
    version="0.1",
    install_requires=['pylint','pytest','flake8','boto3', 'pandas==2.1.4', 'requests', 'sagemaker', 'python-dotenv', 'pycaret', 'tensorflow', 'gunicorn', 'joblib', 'shap']
)