pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "huytruongnguyen/web-test"
        KUBE_NAMESPACE = "gitops"
        SERVICE_NAME = "web-test-service"
        DEPLOYMENT_NAME = "web-test-deployment"
        DOCKERHUB_USERNAME = "huytruongnguyen"
        DOCKERHUB_TOKEN = "dckr_pat_KT4mPY8HZUDpQEvQJNBg_0c6LZ8"
    }
    
    stages {
         stage('Checkout Code') {
            steps {
                // Checkout code from your Git repository using SSH
                git branch: 'master', url: 'git@github.com:FCBTruong/web-test.git', credentialsId: 'github'
            }
        }
        
        stage('Build React App') {
            steps {
                script {
                    // Build the React app using Docker
                    sh 'docker build -t $DOCKER_IMAGE .'
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    // Push the Docker image to Docker Hub
                    sh 'echo $DOCKERHUB_TOKEN | docker login -u $DOCKERHUB_USERNAME --password-stdin'
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }
        
        stage('Deploy to Minikube') {
            steps {
                script {
                    // Use the gitops namespace
                    sh 'kubectl create namespace $KUBE_NAMESPACE || true'
                    
                    // Apply the Kubernetes deployment
                    sh """
                    kubectl apply -f - <<EOF
                    apiVersion: apps/v1
                    kind: Deployment
                    metadata:
                      name: $DEPLOYMENT_NAME
                      namespace: $KUBE_NAMESPACE
                    spec:
                      replicas: 1
                      selector:
                        matchLabels:
                          app: web-test
                      template:
                        metadata:
                          labels:
                            app: web-test
                        spec:
                          containers:
                          - name: web-test
                            image: $DOCKER_IMAGE
                            ports:
                            - containerPort: 3000
                    EOF
                    """
                    
                    // Expose the deployment as a service
                    sh """
                    kubectl expose deployment $DEPLOYMENT_NAME --type=NodePort --name=$SERVICE_NAME --namespace=$KUBE_NAMESPACE
                    """
                }
            }
        }
        
        stage('Expose Service') {
            steps {
                script {
                    // Use Minikube tunnel to expose the service to localhost
                    sh 'minikube service $SERVICE_NAME --namespace=$KUBE_NAMESPACE --url'
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace after the build
            cleanWs()
        }
    }
}
