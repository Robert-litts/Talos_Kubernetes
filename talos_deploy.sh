#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print error messages
error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

# Function to print success messages
success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

# Function to print info messages
info() {
    echo -e "${YELLOW}INFO: $1${NC}"
}

# Print start message
echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}Starting Deployment of Talos Kubernetes Cluster on Proxmox${NC}"
echo -e "${GREEN}=======================================${NC}"
echo

# Function to check Packer version
check_packer_version() {
    if ! command -v packer &> /dev/null; then
        error "Packer is not installed or not in PATH"
        exit 1
    fi
    
    local version=$(packer version | head -n1 | cut -d' ' -f2)
    info "Packer version: $version"
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to validate Packer templates
validate_packer_templates() {
    info "Validating Packer templates..."
    if packer validate \
        -var-file="${SCRIPT_DIR}/packer/local.pkrvars.hcl" \
        "${SCRIPT_DIR}/packer/proxmox.pkr.hcl"; then
        success "Packer templates are valid"
    else
        error "Packer template validation failed"
        exit 1
    fi
}

# Run Packer to build the image
run_packer_build() {
    info "Starting Packer build..."
    if packer build \
        -var-file="${SCRIPT_DIR}/packer/local.pkrvars.hcl" \
        -on-error=ask \
        "${SCRIPT_DIR}/packer/proxmox.pkr.hcl"; then
        success "Packer build completed successfully"
    else
        error "Packer build failed"
        exit 1
    fi
}

# Check Packer version
check_packer_version

# Validate Packer templates
validate_packer_templates

# Run Packer build
run_packer_build

# Initialize Terraform
info "Initializing Terraform..."
if terraform -chdir=terraform init; then
    success "Terraform initialized successfully"
else
    error "Terraform initialization failed"
    exit 1
fi

# Validate Terraform configuration
info "Validating Terraform configuration..."
if terraform -chdir=terraform validate; then
    success "Terraform configuration is valid"
else
    error "Terraform configuration is invalid"
    exit 1
fi

# Plan Terraform changes
info "Planning Terraform changes..."
if terraform -chdir=terraform plan -out=tfplan; then
    success "Terraform plan created successfully"
else
    error "Terraform plan failed"
    exit 1
fi

# Apply Terraform changes
info "Applying Terraform changes..."
if terraform -chdir=terraform apply -auto-approve tfplan; then
    success "Terraform apply completed successfully"
else
    error "Terraform apply failed"
    exit 1
fi

# Optional: Show Terraform output
info "Terraform outputs:"
terraform -chdir=terraform output

success "Deployment completed successfully"
