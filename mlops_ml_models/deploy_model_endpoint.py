from sagemaker.model import Model


def deploy_model(
    model_name: str, instance_type: str, endpoint_name,
    role: str, model_instance_count: int, image_uri: str
) -> None:

    """This script deploys the sagemaker endpoint using the tar.gz file
    saved in s3.

    Args:
        model_name (str): The name of the bucket and name of the file in s3
        instance_type (str): The sagemaker instance type you want to deploy
        endpoint_name (_type_): What you will like to call the endpoint.
        role (str): Your execution role
        model_instance_count (int): initial instance number of model
    """
    model_file = f"s3://{model_name}-model/{model_name}.tar.gz"
    model = Model(
        image_uri=(image_uri),  # The ECR image you pushed
        model_data=model_file,  # Location of your serialized model
        role=role,
    )
    model.deploy(
        initial_instance_count=model_instance_count,
        instance_type=instance_type,
        endpoint_name=endpoint_name,
    )
