import tarfile
import boto3


def save_model_to_s3(
    trained_model_name: str, bucket_name: str
) -> None:
    """This saves the tar.gz model in an s3 bucket

    Args:
        trained_model_name (str): name of the file you are trying to save in s3
        bucket_name (str): name of the bucket you are saving the file
    """
    with tarfile.open(f"{trained_model_name}.tar.gz", "w:gz") as tar:
        tar.add(f"{trained_model_name}.pkl")

    s3 = boto3.client("s3")
    s3.upload_file(
        f"{trained_model_name}.tar.gz", bucket_name,
        f"{trained_model_name}.tar.gz")
