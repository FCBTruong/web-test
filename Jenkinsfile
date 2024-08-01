pipeline {
    agent any

    stages {
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
