pipeline {
    agent { label 'docker-agent' }

    environment {
        DOCKERHUB_USER = "sagarbompada"
        IMAGE_NAME     = "flask-app"
         IMAGE_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
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
                  docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG .
                  docker tag $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG \
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
        
        // stage('Push Image to Docker Hub') {
        //     steps {
        //         sh '''
        //           docker push $DOCKERHUB_USER/$IMAGE_NAME:${BUILD_NUMBER}
        //           docker push $DOCKERHUB_USER/$IMAGE_NAME:latest
        //         '''
        //     }
        // }

        stage('Tag & Push Image to Docker Hub') {
            steps {
                sh '''
                  docker tag flask-app:$IMAGE_TAG $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG
                  docker tag flask-app:$IMAGE_TAG $DOCKERHUB_USER/$IMAGE_NAME:latest
        
                  docker push $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG
                  docker push $DOCKERHUB_USER/$IMAGE_NAME:latest
                '''
                 }
            }
        
        stage('Deploy to Minikube') {
             steps {
                sh '''
                  kubectl apply -f k8s/deployment.yaml
                  kubectl apply -f k8s/service.yaml

                  kubectl set image deployment/flask-app \
                  flask=$DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG

                  kubectl rollout status deployment/flask-app
                '''
    }
}


       stage('Post Deploy Health Check') {
            steps {
                sh '''
                sleep 10
                curl -f https://forminikube.awspractice.online/health
                '''
            }
        }

        stage('Cleanup Local Images') {
            steps {
                sh '''
                  docker rmi $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG || true
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
