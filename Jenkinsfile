pipeline {
    agent {
        label 'kubeagent'
    }
    options {
        skipDefaultCheckout()
    }
    environment {
        DOCKER_IMAGE = "huytruongnguyen/web-test"
        KUBE_NAMESPACE = "gitops"
        SERVICE_NAME = "web-test-service"
        DEPLOYMENT_NAME = "web-test-deployment"
        DOCKER_CONFIG_PATH = "${WORKSPACE}/.docker"
        KANIKO_EXECUTOR_IMAGE = "gcr.io/kaniko-project/executor:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'github', keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                    mkdir -p ~/.ssh
                    cp $SSH_KEY ~/.ssh/id_rsa
                    chmod 600 ~/.ssh/id_rsa
                    ssh-keyscan github.com >> ~/.ssh/known_hosts
                    git clone git@github.com:FCBTruong/web-test.git .
                    '''
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                container('kaniko') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) {
                        script {
                            echo "Pushing image to ${DOCKER_IMAGE}"
                            sh '''
                                mkdir -p /kaniko/.docker

                                echo "Creating docker config.json"
                                cat <<EOF > /kaniko/.docker/config.json
                                {
                                    "auths": {
                                        "https://index.docker.io/v1/": {
                                            "auth": "$(echo -n "${DOCKERHUB_USERNAME}:${DOCKERHUB_TOKEN}" | base64)"
                                        }
                                    }
                                }
                                EOF

                                echo "Docker config.json:"
                                cat /kaniko/.docker/config.json

                                echo "Building and pushing image to ${DOCKER_IMAGE}"

                                /kaniko/executor --dockerfile `pwd`/Dockerfile \
                                    --context `pwd` \
                                    --push-retry 3 \
                                    --destination ${DOCKER_IMAGE} \
                                    --cleanup \
                                    --cache=true \
                                    --cache-repo=${DOCKER_IMAGE}-cache \
                                    --verbosity=debug
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
