### Adding Additional Dependencies

1. if you need to add any additional dependencies to the glue job, add them to the list in `setup.py` in this list:
   
    ```py
    install_requires=['pylint','pytest','flake8','boto3', 'pandas', 'requests', 'sagemaker', 'python-dotenv', 'pycaret', 'tensorflow', 'gunicorn','joblib''shap']
    ```

2. Then you need to run in `~/module/glue/glue_jobs` directory the command:

    ```sh
    python setup.py bdist_wheel
    ```

    or 

    ```sh
    python3 setup.py bdist_wheel
    ```

    **Note**: this must be run on `Python 3.9`

3. Take the `.whl` file found in the `dist` folder out one directory and into the `~/glue/glue_jobs` directory.