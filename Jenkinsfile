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
        // stage('Build and Push Docker Image') {
        //     steps {
        //         container('kaniko') {
        //             withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) {
        //                 script {
        //                     echo "Pushing image to ${DOCKER_IMAGE}"
        //                     sh '''
        //                         echo "Step 1: Create Kaniko Docker directory"
        //                         mkdir -p /kaniko/.docker

        //                         echo "Step 2: Generating base64 encoded auth string"
        //                         AUTH_STRING=$(echo -n "${DOCKERHUB_USERNAME}:${DOCKERHUB_TOKEN}" | base64)

        //                         echo "Step 3: Creating docker config.json"
        //                         echo '{
        //                             "auths": {
        //                                 "https://index.docker.io/v1/": {
        //                                     "auth": "'"$AUTH_STRING"'"
        //                                 }
        //                             }
        //                         }' > /kaniko/.docker/config.json

        //                         echo "Step 4: Showing Docker config.json:"
        //                         cat /kaniko/.docker/config.json

        //                         echo "Step 5: Building and pushing image to ${DOCKER_IMAGE}"

        //                         /kaniko/executor --dockerfile `pwd`/Dockerfile \
        //                             --context `pwd` \
        //                             --push-retry 3 \
        //                             --destination ${DOCKER_IMAGE} \
        //                             --cleanup \
        //                             --cache=true \
        //                             --cache-repo=${DOCKER_IMAGE}-cache \
        //                     '''

        //                 }
        //             }
        //         }
        //     }   
        // }

        stage('Build Helm Chart') {
            steps {
                script {
                    container('helm') {
                        echo "Packaging Helm Chart..."

                        // Package the Helm chart
                        sh '''
                        helm package ${HELM_CHART_PATH} --destination ./charts --version ${BUILD_NUMBER}
                        '''
                    }
                }
            }
        }
        
        stage('Upload to Harbor') {
            steps {
                script {
                    container('helm') {
                        echo "Uploading Helm Chart to Harbor..."

                        // Set Harbor credentials (use credentials store in Jenkins)
                        withCredentials([usernamePassword(credentialsId: 'harbor-creds', passwordVariable: 'HARBOR_PASSWORD', usernameVariable: 'HARBOR_USERNAME')]) {
                           // Helm login to Harbor using HTTP
                            sh '''
                            echo ${HARBOR_PASSWORD} | helm registry login --username ${HARBOR_USERNAME} --password-stdin --insecure ${HARBOR_URL}
                            '''

                            // Push the Helm chart to Harbor using HTTP
                            sh '''
                            helm push ${HELM_CHART_PATH}-chart-${BUILD_NUMBER}.tgz http://${HARBOR_URL}/dev --insecure-skip-tls-verify
                            '''
                        }
                    }
                }
            }
        }

        // Deploy using Helm
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    container('helm') {
                        echo "Deploying to Kubernetes using Helm..."

                        // Update the image in the Helm values and deploy using Helm
                        sh '''
                        helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_PATH} \
                            --set image.repository=${DOCKER_IMAGE} \
                            --set image.tag=latest \
                            --namespace ${KUBE_NAMESPACE} --create-namespace
                        '''
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
