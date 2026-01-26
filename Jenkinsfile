pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

         stage('Run Health Test') {
            steps {
                sh '''
                  ./venv/bin/python - <<EOF
from app import app
client = app.test_client()
response = client.get("/health")
assert response.data == b"Healthy"
print("Health endpoint test passed")
EOF
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                  docker build -t flask-app:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Run Container') {
            steps {
                sh '''
                  docker run -d --name flask-ci -p 5000:5000 flask-app:${BUILD_NUMBER}
                  sleep 5
                '''
            }
        }

        stage('Container Health Check') {
            steps {
                sh '''
                  curl -f http://localhost:5000/health
                '''
            }
        }

        stage('Cleanup') {
            steps {
                sh '''
                  docker rm -f flask-ci || true
                '''
            }
        }

    }

    post {
        success {
            echo "✅ Jenkins CI + Docker pipeline completed successfully!"
        }
        failure {
            echo "❌ Jenkins CI + Docker pipeline failed!"
        }
        always {
            sh 'docker rm -f flask-ci || true'
        }
    }
}
