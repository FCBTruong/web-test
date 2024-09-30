# React App CI/CD with Jenkins, Docker, and ArgoCD

## Overview
This repository demonstrates a CI/CD pipeline setup for a React web application. The pipeline is automated using **Jenkins** for building and testing the application, **Docker** for containerizing it, **Docker Hub** for storing images, and **ArgoCD** for deploying the application to a **Minikube** Kubernetes cluster.

### Workflow:
1. **Continuous Integration (CI)**: 
   - Every code commit triggers a Jenkins job that builds the React app and creates a Docker image.
   - The image is automatically pushed to **Docker Hub**.
  
2. **Continuous Deployment (CD)**:
   - **ArgoCD** automatically detects the new image in Docker Hub and deploys the updated container to the **Minikube** Kubernetes cluster.

## Tools Used
- **React**: Frontend framework used to build the web application.
- **Jenkins**: Automates the build, test, and Docker image creation process.
- **Docker**: Used to containerize the React app for consistent deployment.
- **Docker Hub**: Stores the Docker images created by Jenkins.
- **Minikube**: Local Kubernetes cluster used to host the application.
- **ArgoCD**: Manages the continuous deployment to Minikube.

## Setup Instructions

### 1. Prerequisites
- [Jenkins](https://www.jenkins.io/) installed and configured.
- [Docker](https://www.docker.com/) installed and configured.
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) installed and running.
- [ArgoCD](https://argoproj.github.io/argo-cd/) installed on the Minikube cluster.
- A [Docker Hub](https://hub.docker.com/) account.

### 2. Clone the Repository
```bash
git clone https://github.com/yourusername/react-app-ci-cd.git
cd react-app-ci-cd
