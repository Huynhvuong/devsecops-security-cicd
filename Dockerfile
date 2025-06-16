# Use the official Python image from the Docker Hub
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Copy the pyproject.toml file into the container
COPY pyproject.toml poetry.lock poetry.toml ./

# Install Poetry
RUN pip install --no-cache-dir poetry

# Optional build arg for dev dependencies
ARG INSTALL_DEV=false
RUN if [ "$INSTALL_DEV" = "true" ]; then poetry install --no-interaction; else poetry install --no-root --no-interaction; fi

# Install AWS CLI v2
RUN apt-get update && \
    apt-get install -y curl unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws
    
# Copy the rest of the application code into the container
COPY . .
RUN chmod +x run.sh
# Expose the port the app runs on
EXPOSE 3000

CMD ["bash", "-c", "ls -al && /bin/bash run.sh"]