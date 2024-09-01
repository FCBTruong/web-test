pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "huytruongnguyen/web-test"
        KUBE_NAMESPACE = "gitops"
        SERVICE_NAME = "web-test-service"
        DEPLOYMENT_NAME = "web-test-deployment"
        DOCKER_CONFIG_PATH = "${WORKSPACE}/.docker"
        KANIKO_EXECUTOR_IMAGE = "gcr.io/kaniko-project/executor:latest"
    }

    stages {
        stage('Prepare Environment') {
            steps {
                script {
                    // Ensure the .ssh directory exists
                    sh 'mkdir -p ~/.ssh'
                    // Add GitHub's SSH host key to known_hosts
                    sh 'ssh-keyscan github.com >> ~/.ssh/known_hosts'
                }
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'git@github.com:FCBTruong/web-test.git', credentialsId: 'github'
            }
        }

        stage('Build and Push Docker Image') {
            agent {
                label 'kubeagent'
            }
            steps {
                container('kaniko') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) {
                        sh '''
                        mkdir -p ${DOCKER_CONFIG_PATH}
                        echo "{\"auths\":{\"https://index.docker.io/v1/\":{\"username\":\"${DOCKERHUB_USERNAME}\",\"password\":\"${DOCKERHUB_TOKEN}\"}}}" > ${DOCKER_CONFIG_PATH}/config.json
                        '''

                        sh '''
                        /kaniko/executor --dockerfile `pwd`/Dockerfile \
                            --context `pwd` \
                            --destination ${DOCKER_IMAGE} \
                            --cleanup \
                            --cache=true \
                            --cache-repo=${DOCKER_IMAGE}-cache
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying to Kubernetes..."
                // Example:
                // sh 'kubectl apply -f deployment.yaml -n ${KUBE_NAMESPACE}'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
