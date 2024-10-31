from setuptools import setup

setup(
    name="mlops_dependencies_module",
    version="0.1",
    install_requires=['pylint','pytest','flake8','boto3', 'pandas', 'requests', 'sagemaker', 'python-dotenv', 'pycaret', 'tensorflow', 'gunicorn', 'joblib', 'shap']
)

# run python setup.py bdist_wheel to build .whl file