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
        HELM_RELEASE_NAME = "web-test-release"
        HELM_CHART_PATH = "./charts/web-test"  // Path to your Helm chart directory
        HARBOR_URL = "192.168.49.2:30002"
        KUBECONFIG_PATH = "/root/.kube/config"  // Path where kubeconfig will be placed inside the container
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
                    git clone git@github.com:FCBTruong/web-test-ci-cd.git .
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    container('helm') {
                        echo "Deploying to Kubernetes using Helm..."

                        // Helm command to deploy the chart
                        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBE_CONFIG')]) {
                            sh '''
                            set -e

                            echo "Copying kubeconfig into container..."
                            mkdir -p /root/.kube
                            cp ${KUBE_CONFIG} /root/.kube/config
                            chmod 600 /root/.kube/config

                            echo "Verifying Kubernetes context..."
                            kubectl --kubeconfig /root/.kube/config config current-context

                            echo "Running Helm upgrade/install command..."
                            helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_PATH} \
                                --set image.repository=${DOCKER_IMAGE} \
                                --set image.tag=latest \
                                --namespace ${KUBE_NAMESPACE} --create-namespace \
                                --kubeconfig /root/.kube/config

                            echo "Helm deployment completed."
                            '''
                        }
                    }
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
