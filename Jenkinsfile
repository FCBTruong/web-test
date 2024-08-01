pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image with Kaniko') {
            steps {
                script {
                    // Define the Kubernetes Job YAML file for Kaniko
                    writeFile file: 'kaniko-job.yaml', text: """
                    apiVersion: batch/v1
                    kind: Job
                    metadata:
                      name: kaniko-build-${env.BUILD_ID}
                    spec:
                      backoffLimit: 0
                      template:
                        spec:
                          containers:
                          - name: kaniko
                            image: gcr.io/kaniko-project/executor:latest
                            args:
                            - "--dockerfile=Dockerfile"
                            - "--context=git://github.com/your-repo/your-project.git#main"
                            - "--destination=docker.io/your-username/web-test-ui:${env.BUILD_ID}"
                            env:
                            - name: DOCKER_CONFIG
                              value: /kaniko/.docker/
                            volumeMounts:
                            - name: docker-config
                              mountPath: /kaniko/.docker/
                          restartPolicy: Never
                          volumes:
                          - name: docker-config
                            secret:
                              secretName: regcred
                    """
                    // Apply the Kubernetes Job
                    sh 'kubectl apply -f kaniko-job.yaml'

                    // Wait for the Job to complete
                    sh 'kubectl wait --for=condition=complete job/kaniko-build-${env.BUILD_ID} --timeout=600s'
                }
            }
        }
        stage('Run Tests in Docker') {
            steps {
                script {
                    // Assuming the image is available, run the tests inside the new Docker image
                    docker.image("your-username/web-test-ui:${env.BUILD_ID}").inside {
                        sh 'npm test'
                    }
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    // Since the image is already pushed by Kaniko, this stage might be optional
                    // Here we assume you're using a different tag for 'latest'
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                        sh 'docker pull docker.io/your-username/web-test-ui:${env.BUILD_ID}' // Pull the image
                        docker.image("your-username/web-test-ui:${env.BUILD_ID}").tag('latest')
                        docker.image('your-username/web-test-ui').push('latest')
                    }
                }
            }
        }
    }
}
