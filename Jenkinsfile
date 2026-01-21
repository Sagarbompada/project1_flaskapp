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

    }

    post {
        success {
            echo "CI Pipeline completed successfully!"
        }
        failure {
            echo "CI Pipeline failed!"
        }
    }
}
