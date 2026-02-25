pipeline {
    agent { label 'docker-agent' }

    environment {
        DOCKERHUB_USER = "sagarbompada"
        IMAGE_NAME     = "flask-app"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Setup Virtual Environment & Install Deps') {
            steps {
                sh '''
                  rm -rf venv
                  python3 -m venv venv
                  ./venv/bin/python -m pip install --upgrade pip
                  ./venv/bin/python -m pip install -r requirements.txt
                '''
            }
        }

        stage('Run Health Test') {
            steps {
                sh '''
                  ./venv/bin/python - <<EOF
from app import app

client = app.test_client()
response = client.get("/health")

assert response.data.strip() == b"Healthy"
print("Health endpoint test passed")
EOF
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                  docker build -t $DOCKERHUB_USER/$IMAGE_NAME:${BUILD_NUMBER} .
                  docker tag $DOCKERHUB_USER/$IMAGE_NAME:${BUILD_NUMBER} \
                             $DOCKERHUB_USER/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh '''
                  docker push $DOCKERHUB_USER/$IMAGE_NAME:${BUILD_NUMBER}
                  docker push $DOCKERHUB_USER/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Cleanup Local Images') {
            steps {
                sh '''
                  docker rmi $DOCKERHUB_USER/$IMAGE_NAME:${BUILD_NUMBER} || true
                  docker rmi $DOCKERHUB_USER/$IMAGE_NAME:latest || true
                '''
            }
        }
    }

    post {
        success {
            echo "✅ CI + Docker Hub pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
