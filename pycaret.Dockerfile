FROM pycaret/full:latest

USER root

LABEL maintainer Amazon AI <sage-learner@amazon.com>

RUN apt-get clean && \
    apt-get -q update && \
    apt-get -q install -y --no-install-recommends --fix-missing \
    wget build-essential gcc nginx ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Set some environment variables. PYTHONUNBUFFERED keeps Python from buffering our standard
# output stream, which means that logs can be delivered to the user quickly. PYTHONDONTWRITEBYTECODE
# keeps Python from writing the .pyc files which are unnecessary in this case. We also update
# PATH so that the train and serve programs are found when the container is invoked.

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/opt/program:${PATH}"

# Set up the program in the image
COPY pycaret_image_files /opt/program
WORKDIR /opt/program