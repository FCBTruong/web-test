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
                // Checkout code from your Git repository
                git branch: 'master', url: 'git@github.com:FCBTruong/web-test.git', credentialsId: 'github'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Build Docker image with Kaniko
                sh '''
                    echo '{"auths":{"https://index.docker.io/v1/":{"auth":"$(echo -n ${DOCKERHUB_USERNAME}:${DOCKERHUB_TOKEN} | base64)"}}}' > /kaniko/.docker/config.json
                    /kaniko/executor \
                    --context /workspace \
                    --dockerfile /workspace/Dockerfile \
                    --destination ${DOCKER_IMAGE}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Deploy with Helm') {
            steps {
                // Deploy the application to Kubernetes using Helm
                sh '''
                    helm upgrade --install web-test ./charts/web-test \
                    --namespace ${KUBE_NAMESPACE} \
                    --set image.repository=${DOCKER_IMAGE} \
                    --set image.tag=${BUILD_NUMBER} \
                    --set service.name=${SERVICE_NAME} \
                    --set deployment.name=${DEPLOYMENT_NAME}
                '''
            }
        }
    }

    post {
        always {
            cleanWs() // Clean up workspace after the build
        }
    }
}
