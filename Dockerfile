FROM python:3.8.19-slim-bullseye

WORKDIR /src

# Install system dependencies
RUN apt update -y && \
    apt install -y build-essential libpq-dev && \
    apt clean

# Copy requirements and install Python dependencies
COPY ./analytics/requirements.txt requirements.txt
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

# Copy the rest of the application code
COPY . .

# Set environment variables
ARG DB_USERNAME=$DB_USERNAME
ARG DB_PASSWORD=$DB_PASSWORD
ARG DB_HOST=$DB_HOST
ARG DB_PORT=$DB_PORT
ARG DB_NAME=$DB_NAME

RUN apt install postgresql postgresql-contrib -y
RUN PGPASSWORD="$DB_PASSWORD" psql --host $DB_HOST -U $DB_USERNAME -d $DB_NAME -p $DB_PORT < db/1_create_tables.sql
RUN PGPASSWORD="$DB_PASSWORD" psql --host $DB_HOST -U $DB_USERNAME -d $DB_NAME -p $DB_PORT < db/2_seed_users.sql
RUN PGPASSWORD="$DB_PASSWORD" psql --host $DB_HOST -U $DB_USERNAME -d $DB_NAME -p $DB_PORT < db/3_seed_tokens.sql

# Start the application
CMD ["python", "app.py"]