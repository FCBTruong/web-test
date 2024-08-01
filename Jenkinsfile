pipeline {
    agent any

    stages {
        stage('Set Docker Environment') {
            steps {
                script {
                    sh 'eval $(minikube -p minikube docker-env)' // Setup to use Minikube's Docker
                }
            }
        }
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('web-test-ui')
                }
            }
        }
        stage('Run Tests in Docker') {
            steps {
                script {
                    docker.image('web-test-ui').inside {
                        sh 'npm test'
                    }
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                        docker.image('web-test-ui').push('latest')
                    }
                }
            }
        }
    }
}
