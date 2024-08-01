pipeline {
    agent any

    environment {
        DOCKER_HOST = ''
        DOCKER_TLS_VERIFY = ''
        DOCKER_CERT_PATH = ''
        DOCKER_API_VERSION = ''
    }

    stages {
        stage('Set Docker Environment') {
            steps {
                script {
                    def dockerEnv = sh(script: 'minikube -p minikube docker-env', returnStdout: true).trim()
                    def envVars = dockerEnv.split("\n").collectEntries { line ->
                        def keyValue = line.tokenize('=')
                        keyValue.size() == 2 ? [(keyValue[0]): keyValue[1].replace('"', '')] : [:]
                    }
                    envVars.each { key, value ->
                        env[key] = value
                    }
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
