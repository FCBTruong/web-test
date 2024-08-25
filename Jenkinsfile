pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "huytruongnguyen/web-test"
        KUBE_NAMESPACE = "gitops"
        SERVICE_NAME = "web-test-service"
        DEPLOYMENT_NAME = "web-test-deployment"
        DOCKERHUB_USERNAME = "huytruongnguyen"
        DOCKERHUB_TOKEN = "dckr_pat_KT4mPY8HZUDpQEvQJNBg_0c6LZ8"
        DOCKER_CONFIG_PATH = "${WORKSPACE}/.docker"
        KANIKO_EXECUTOR_PATH = "${WORKSPACE}/kaniko/executor"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'git@github.com:FCBTruong/web-test.git', credentialsId: 'github'
            }
        }

        stage('Install Kaniko') {
            steps {
                script {
                    sh """
                        mkdir -p $(dirname ${KANIKO_EXECUTOR_PATH})
                        curl -sSL https://github.com/GoogleContainerTools/kaniko/releases/download/v1.5.0/executor -o ${KANIKO_EXECUTOR_PATH}
                        chmod +x ${KANIKO_EXECUTOR_PATH}
                        ls -l ${KANIKO_EXECUTOR_PATH}  # Check the file
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        mkdir -p ${DOCKER_CONFIG_PATH}
                        echo '{"auths":{"https://index.docker.io/v1/":{"auth":"\$(echo -n ${DOCKERHUB_USERNAME}:${DOCKERHUB_TOKEN} | base64)"}}}' > ${DOCKER_CONFIG_PATH}/config.json

                        ${KANIKO_EXECUTOR_PATH} \
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
            cleanWs()
        }
    }
}
