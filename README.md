# Scalable Web Application Stack

## Overview
This project provides a complete setup for deploying a two-tier Python-based application (backend + frontend) on AWS EKS using Terraform, Kubernetes manifests, and ArgoCD for GitOps. The application interacts with a MySQL database and is fully containerized.

## Folder Structure

```
.
├── .github         # CI/CD Pipelines
├── infra/          # Terraform scripts to provision ECR and EKS
├── src/            # Source code for backend, frontend, and database Docker setup
│   ├── backend/    # Backend Python app with Flask (API service)
│   ├── frontend/   # Frontend Python app with Flask (UI service)
│   └── database/   # MySQL initialization script
├── manifest/       # Kubernetes manifests to deploy the app on EKS
├── argocd/         # ArgoCD configurations for GitOps-based app sync
└── README.md       # Project documentation
```

## Prerequisites
Ensure you have the following installed on your system
- Terraform
- AWS CLI
- kubectl
- Docker
- ArgoCD server
- ArgoCD CLI

## Setup Instructions

### AWS Configuration: Assume you have an AWS account with fully permission
1. Configure AWS credentials:
```
aws configure
```
2. Ensure you have an IAM role with sufficient permissions to provision resources on AWS

### Step 1: Prepare credentials for infrastructure
1. Create an IAM role to be used by GitHub Actions for provisioning the infrastructure (running Terraform):
    - Trusted entity type: Web Identity
    - identity provider: Provide necessary GitHub information (GitHub org, repo, branch, etc.)
    - Permission policies: Assign appropriate policies (EKS, EC2, ECR, IAM, etc.)
2. Update the workflow to use this IAM role for Terraform steps:
```
- name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
        role-to-assume: arn:aws:iam::<aws_account>:role/<iam_role>
        aws-region: ap-southeast-1
```
## Deployment Steps:
### Provision Infrastructure: (refer `EKS-deploy` workflow job)
Navigate to the `infra` folder and use Terraform to provision AWS resources:
```
cd infra/ECR #(and EKS)
terraform init
terraform plan
terraform apply --auto-approve
```
This will create an EKS cluster and ECR to store Docker images

### Build and Push Docker Images: (refer `build` workflow job)
Build the backend and frontend Docker images and push them to ECR:
```
cd src
# Backend
docker build -t <ecr-repo-backend>:<tag> -f backend/Dockerfile .
docker push <ecr-repo-backend>:<tag>

# Frontend
docker build -t <ecr-repo-frontend>:<tag> -f frontend/Dockerfile .
docker push <ecr-repo-frontend>:<tag>
```

### Update image tag for ArgoCD sync application with EKS cluster (refer: `update-web-app-deployment` workflow job)
Navigate to the `manifest` folder, and update every imageTag with latest pushed image

##Setup GitOps with ArgoCD

1. Install ArgoCD on EKS (or local machine, using Docker and minikube)
2. Sync your application using the ArgoCD configuration in `argocd`:
```
kubectl apply -f argocd.yaml
```
