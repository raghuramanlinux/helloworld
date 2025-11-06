# Base image
FROM python:3.10-slim

# Working directory
WORKDIR /app

# Copy files
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .

# Expose the app port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
