from setuptools import setup

setup(
    name="mlops_dependencies_module",
    version="0.1",
    install_requires=['pylint','pytest','flake8','boto3', 'pandas', 'requests', 'sagemaker', 'python-dotenv', 'pycaret', 'tensorflow', 'gunicorn', 'joblib', 'shap', 'fsspec==2023.5.0', 's3fs=2023.5.0']
)