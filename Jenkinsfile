pipeline {
    agent any

    environment {
        APP_NAME = "go-jenkins-ci-cd-app"
        DOCKER_REGISTRY = "docker.io"                      // change if using another registry
        DOCKER_REPO = "tmreddy/${APP_NAME}"           // replace with your DockerHub/org
        CONTAINER_NAME = "go-jenkins-ci-cd-app"
        APP_PORT = "8000"                                  // app exposed port
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
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin docker.io
                        docker push $DOCKER_IMAGE
                        docker push $LATEST_IMAGE
                    '''
                }

            }
        }

        // stage('Run Unit Tests') {
        //     steps {
        //         script {
        //             // Run Go tests inside container
        //             sh "docker run --rm ${DOCKER_IMAGE} go test ./..."
        //         }
        //     }
        // }

        stage('Deploy') {
            steps {
                script {
                    // Force remove any existing container
                    sh """
                        docker rm -f ${CONTAINER_NAME} || true
                    """
        
                    // Pull the latest built image
                    sh """
                        docker pull ${DOCKER_IMAGE}
                    """
        
                    // Run the container mapping host $APP_PORT to container's 8080
                    sh """
                        docker run -d --name ${CONTAINER_NAME} -p ${APP_PORT}:${APP_PORT} ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sleep 10
                    sh """
                        curl -f http://localhost:${APP_PORT}/health || (echo 'App failed health check' && exit 1)
                    """
                }
            }
        }
    }
}
