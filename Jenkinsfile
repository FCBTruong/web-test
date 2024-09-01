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
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'git@github.com:FCBTruong/web-test.git', credentialsId: 'github'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentials
                    Id: 'dockerhub', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) {
                        sh '''
                            echo "Building Docker image..."
                            docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_TOKEN}
                            docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            if [ $? -ne 0 ]; then
                                echo "Error building Docker image. Exiting."
                                exit 1
                            fi
                        '''
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
