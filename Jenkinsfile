pipeline {
    agent any

    environment {
        AWS_REGION    = "us-east-1" 
        AWS_ACCOUNT_ID = "390844761974"
        ECR_REPO      = "project1-flask"
        IMAGE_NAME    = "flask-app"
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
                  docker build -t $IMAGE_NAME:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Login to AWS ECR') {
            steps {
                sh '''
                  aws ecr get-login-password --region $AWS_REGION \
                  | docker login --username AWS --password-stdin \
                  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh '''
                  docker tag $IMAGE_NAME:${BUILD_NUMBER} \
                  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:${BUILD_NUMBER}

                  docker tag $IMAGE_NAME:${BUILD_NUMBER} \
                  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                  docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:${BUILD_NUMBER}
                  docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest
                '''
            }
        }
    }

    post {
        success {
            echo "✅ CI + Docker + AWS ECR pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
        always {
            sh 'docker rm -f flask-ci || true'
        }
    }
}
