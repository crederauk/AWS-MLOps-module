import boto3


def delete_sagemaker_endpoint(endpoint_name: str) -> None:
    """
    Deletes the specified SageMaker endpoint and its configuration after user
    confirmation.

    This function first asks the user to confirm the deletion. If the user
    confirms,
    it proceeds to delete the SageMaker endpoint and its associated
    configuration.

    Args:
        endpoint_name (str): The name of the SageMaker endpoint to delete.
        region_name (str): The AWS region where the SageMaker endpoint is
        located.
    """
    # Create SageMaker client
    my_session = boto3.session.Session()
    my_region = my_session.region_name
    sagemaker_client = boto3.client("sagemaker", region_name=my_region)

    # Ask for user confirmation
    confirmation = input(
        f"Are you sure you want to delete the endpoint '{endpoint_name}'? "
        "Type 'Yes' to confirm: "
    )

    if confirmation.lower() == "yes":
        # Delete endpoint
        sagemaker_client.delete_endpoint(EndpointName=endpoint_name)

        # Delete endpoint configuration
        sagemaker_client.delete_endpoint_config(
            EndpointConfigName=endpoint_name
        )

        print(f"Endpoint '{endpoint_name}' and its configuration have "
              "been deleted.")
    else:
        print("Endpoint deletion cancelled.")
