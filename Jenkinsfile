pipeline {
    agent any

    environment {
        APP_NAME = "go-jenkins-CI-CD-app"
        DOCKER_REGISTRY = "docker.io"                      // change if using another registry
        DOCKER_REPO = "tmreddy/${APP_NAME}"           // replace with your DockerHub/org
        CONTAINER_NAME = "go-jenkins-CI-CD-app"
        APP_PORT = "8080"                                  // app exposed port
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/tmreddy/Go-Jenkins-CI-CD.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    COMMIT_SHA = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    IMAGE_TAG = "${COMMIT_SHA}"
                    env.DOCKER_IMAGE = "${DOCKER_REPO}:${IMAGE_TAG}"
                    env.LATEST_IMAGE = "${DOCKER_REPO}:latest"

                    sh """
                        docker build -t ${DOCKER_IMAGE} -t ${LATEST_IMAGE} .
                    """
                }
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin ${DOCKER_REGISTRY}
                        docker push ${DOCKER_IMAGE}
                        docker push ${LATEST_IMAGE}
                    """
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    // Run Go tests inside container
                    sh "docker run --rm ${DOCKER_IMAGE} go test ./..."
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Stop & remove existing container if running
                    sh '''docker ps -q --filter name=${CONTAINER_NAME} | grep -q . && docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME} || true'''

                    // Always pull latest tagged image from Docker Hub
                    sh """
                        docker pull ${DOCKER_IMAGE}
                        docker run -d --name ${CONTAINER_NAME} -p ${APP_PORT}:${APP_PORT} ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sleep 5
                    sh """
                        curl -f http://localhost:${APP_PORT}/health || (echo 'App failed health check' && exit 1)
                    """
                }
            }
        }
    }
}
