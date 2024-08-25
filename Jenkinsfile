pipeline {
    agent any

    environment {
        KANIKO_VERSION = "v1.23.2"
        KANIKO_ZIP = "v1.23.2.zip"
        KANIKO_DIR = "${WORKSPACE}/kaniko-${KANIKO_VERSION}"
        DOCKER_IMAGE = "huytruongnguyen/web-test"
        KUBE_NAMESPACE = "gitops"
        SERVICE_NAME = "web-test-service"
        DEPLOYMENT_NAME = "web-test-deployment"
        DOCKERHUB_USERNAME = "huytruongnguyen"
        DOCKERHUB_TOKEN = "dckr_pat_KT4mPY8HZUDpQEvQJNBg_0c6LZ8"
        DOCKER_CONFIG_PATH = "${WORKSPACE}/.docker"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'git@github.com:FCBTruong/web-test.git', credentialsId: 'github'
            }
        }

        stage('Download and Unzip Kaniko') {
            steps {
                sh '''
                    echo "Downloading Kaniko..."
                    curl -sSL https://github.com/GoogleContainerTools/kaniko/archive/refs/tags/${KANIKO_VERSION}.zip -o ${KANIKO_ZIP}
                    if [ $? -ne 0 ]; then
                        echo "Error downloading Kaniko. Exiting."
                        exit 1
                    fi

                    echo "Unzipping Kaniko..."
                    unzip -q ${KANIKO_ZIP} -d ${WORKSPACE}
                    if [ $? -ne 0 ]; then
                        echo "Error unzipping Kaniko. Exiting."
                        exit 1
                    fi
                '''
            }
        }

        stage('Build Kaniko Executor') {
            steps {
                sh '''
                    cd ${KANIKO_DIR}
                    echo "Downloading Go modules..."
                    go mod download
                    if [ $? -ne 0 ]; then
                        echo "Error downloading Go modules. Exiting."
                        exit 1
                    fi

                    echo "Building Kaniko Executor..."
                    go build -o executor cmd/executor/main.go
                    if [ $? -ne 0 ]; then
                        echo "Error building Kaniko Executor. Exiting."
                        exit 1
                    fi
                '''
            }
        }

        stage('Build Docker Image with Kaniko') {
            steps {
                script {
                    sh '''
                        mkdir -p ${DOCKER_CONFIG_PATH}
                        echo '{"auths":{"https://index.docker.io/v1/":{"auth":"'$(echo -n ${DOCKERHUB_USERNAME}:${DOCKERHUB_TOKEN} | base64)'"}}}' > ${DOCKER_CONFIG_PATH}/config.json

                        echo "Building Docker image with Kaniko..."
                        ${KANIKO_DIR}/executor \
                        --dockerfile ${WORKSPACE}/Dockerfile \
                        --context ${WORKSPACE} \
                        --destination ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        --docker-config=${DOCKER_CONFIG_PATH}
                        if [ $? -ne 0 ]; then
                            echo "Error building Docker image with Kaniko. Exiting."
                            exit 1
                        fi
                    '''
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
