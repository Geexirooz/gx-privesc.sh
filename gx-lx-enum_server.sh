#!/bin/bash

# Define paths as variables
PWD_DIR="$PWD"
UPLOAD_SERVER_DIR="$PWD_DIR/https"
CERTIFICATE_PATH="$PWD_DIR/server.pem"

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Function to create a self-signed certificate
create_certificate() {
    echo "Creating self-signed certificate..."
    openssl req -x509 -out "$CERTIFICATE_PATH" -keyout "$CERTIFICATE_PATH" -newkey rsa:2048 -nodes -sha256 -subj '/CN=server' || handle_error "Failed to create self-signed certificate"
}

# Function to start the upload server
start_upload_server() {
    echo "Starting upload server..."
    mkdir -p "$UPLOAD_SERVER_DIR" && cd "$UPLOAD_SERVER_DIR" || handle_error "Failed to change directory to $UPLOAD_SERVER_DIR"
    sudo python3 -m uploadserver 443 --server-certificate "$CERTIFICATE_PATH" || handle_error "Failed to start upload server"
}

# Main script execution
create_certificate
start_upload_server
