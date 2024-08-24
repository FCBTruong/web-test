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
        
        stage('Build and Push Docker Image with Kaniko') {
            steps {
                script {
                    // Create a Kubernetes job to build and push the Docker image using Kaniko
                    sh """
                    kubectl create namespace $KUBE_NAMESPACE || true
                    
                    kubectl apply -f - <<EOF
                    apiVersion: batch/v1
                    kind: Job
                    metadata:
                      name: kaniko-build
                      namespace: $KUBE_NAMESPACE
                    spec:
                      template:
                        spec:
                          containers:
                          - name: kaniko
                            image: gcr.io/kaniko-project/executor:latest
                            args:
                            - --dockerfile=Dockerfile
                            - --context=git://github.com/FCBTruong/web-test.git#master
                            - --destination=$DOCKER_IMAGE
                            - --insecure
                            env:
                            - name: DOCKER_CONFIG
                              value: /kaniko/.docker/
                            volumeMounts:
                            - name: docker-config
                              mountPath: /kaniko/.docker/
                          restartPolicy: Never
                          volumes:
                          - name: docker-config
                            configMap:
                              name: kaniko-docker-config
                      backoffLimit: 1
                    EOF
                    """
                    
                    // Wait for the Kaniko job to complete
                    sh 'kubectl wait --for=condition=complete --timeout=600s job/kaniko-build --namespace=$KUBE_NAMESPACE'
                    
                    // Clean up the Kaniko job
                    sh 'kubectl delete job kaniko-build --namespace=$KUBE_NAMESPACE'
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
