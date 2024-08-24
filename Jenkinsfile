pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "huytruongnguyen/web-test"
        KUBE_NAMESPACE = "gitops"
        SERVICE_NAME = "web-test-service"
        DEPLOYMENT_NAME = "web-test-deployment"
        DOCKERHUB_USERNAME = "huytruongnguyen"
        DOCKERHUB_TOKEN = "dckr_pat_KT4mPY8HZUDpQEvQJNBg_0c6LZ8"
        DOCKER_CONFIG_PATH = '/tmp/.docker'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout code from your Git repository
                git branch: 'master', url: 'git@github.com:FCBTruong/web-test.git', credentialsId: 'github'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Create Docker config file for Kaniko in a writable directory
                    sh """
                        mkdir -p ${DOCKER_CONFIG_PATH}
                        echo '{"auths":{"https://index.docker.io/v1/":{"auth":"\$(echo -n ${DOCKERHUB_USERNAME}:${DOCKERHUB_TOKEN} | base64)"}}}' > ${DOCKER_CONFIG_PATH}/config.json
                    """
                    
                    // Build Docker image with Kaniko
                    sh """
                        /kaniko/executor \
                        --dockerfile /workspace/Dockerfile \
                        --context /workspace \
                        --destination ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        --docker-config=${DOCKER_CONFIG_PATH}
                    """
                }
            }
        }

        stage('Deploy with Helm') {
            steps {
                script {
                    // Deploy the application to Kubernetes using Helm
                    sh """
                        helm upgrade --install ${DEPLOYMENT_NAME} ./charts/web-test \
                        --namespace ${KUBE_NAMESPACE} \
                        --set image.repository=${DOCKER_IMAGE} \
                        --set image.tag=${BUILD_NUMBER} \
                        --set service.name=${SERVICE_NAME} \
                        --set deployment.name=${DEPLOYMENT_NAME}
                    """
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
