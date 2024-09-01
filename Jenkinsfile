pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "huytruongnguyen/web-test"
        KUBE_NAMESPACE = "gitops"
        SERVICE_NAME = "web-test-service"
        DEPLOYMENT_NAME = "web-test-deployment"
        DOCKER_CONFIG_PATH = "${WORKSPACE}/.docker"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'git@github.com:FCBTruong/web-test.git', credentialsId: 'github'
            }
        }

         stage('Build and Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) {
                    container('kaniko') {
                        script {
                            sh '''
                            echo "Building and pushing Docker image with Kaniko..."

                            # Create a Docker config.json file with the DockerHub credentials
                            mkdir -p /kaniko/.docker
                            cat > /kaniko/.docker/config.json <<EOL
                            {
                                "auths": {
                                    "https://index.docker.io/v1/": {
                                        "auth": "$(echo -n ${DOCKERHUB_USERNAME}:${DOCKERHUB_TOKEN} | base64)"
                                    }
                                }
                            }
                            EOL

                            # Use Kaniko to build and push the Docker image
                            /kaniko/executor \
                                --context . \
                                --dockerfile Dockerfile \
                                --destination docker.io/${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${BUILD_NUMBER}

                            if [ $? -ne 0 ]; then
                                echo "Error building Docker image with Kaniko. Exiting."
                                exit 1
                            fi
                            '''
                        }
                    }
                }
            }
        }

        stage('Deploy with Helm') {
            steps {
                script {
                    sh '''
                        echo "Deploying with Helm..."
                        helm upgrade --install ${DEPLOYMENT_NAME} ./charts/web-test \
                        --namespace ${KUBE_NAMESPACE} \
                        --set image.repository=${DOCKER_IMAGE} \
                        --set image.tag=${BUILD_NUMBER} \
                        --set service.name=${SERVICE_NAME} \
                        --set deployment.name=${DEPLOYMENT_NAME}
                        if [ $? -ne 0 ]; then
                            echo "Error deploying with Helm. Exiting."
                            exit 1
                        fi
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
