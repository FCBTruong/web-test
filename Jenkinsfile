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
                    git clone git@github.com:FCBTruong/web-test.git
                    '''
                }
                // check has code
                sh 'ls -la web-test'
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                sh 'ls -la /home/jenkins/workspace/web-test-pipeline'
                sh 'ls -la `pwd`/Dockerfile'
                container('kaniko') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) {
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
