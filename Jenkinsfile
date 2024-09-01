pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "huytruongnguyen/web-test"
        KUBE_NAMESPACE = "gitops"
        SERVICE_NAME = "web-test-service"
        DEPLOYMENT_NAME = "web-test-deployment"
        KANIKO_EXECUTOR_IMAGE = "gcr.io/kaniko-project/executor:latest"
    }

    stages {
        stage('Prepare Environment') {
            steps {
                script {
                    // Add GitHub to known_hosts to avoid host key verification issues
                    sh 'mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts'
                }
            }
        }

        stage('Build and Push Docker Image') {
            agent {
                label 'kubeagent'
            }
            steps {
                container('kaniko') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) {
                        script {
                            // Kaniko build steps (previously discussed)
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
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying to Kubernetes..."
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
