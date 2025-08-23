# Use a slim Python base image
FROM --platform=linux/amd64 python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN apt-get update && apt-get install -y procps

# Copy the application code
COPY . .

# Expose the port the application listens on
EXPOSE 8080

ENTRYPOINT ["/app/start.sh"]
