pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                  python3 -m venv venv
                  . venv/bin/activate
                  pip3 install -r requirements.txt
                '''
            }
        }

        stage('Run Unit Test') {
            steps {
                sh '''
                  . venv/bin/activate
                  python - <<EOF
from app import app
client = app.test_client()
response = client.get("/health")
assert response.data == b"OK"
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
