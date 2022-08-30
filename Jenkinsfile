pipeline {
    agent any

    tools {
        maven '3.8.4'
    }
    parameters {
        booleanParam(name: 'PROD_BUILD', defaultValue: true, description: 'Enble this as a production build')
        string(name: 'SERVER_IP', defaultValue: '127.0.0.1', description: 'Provide production server IP Address.')
        string(name: 'SSH_USER', defaultValue: 'ubuntu', description: 'Provide SSH username.')
    }

    stages {
        stage('Source') {
            steps {
                git branch: 'main', changelog: false, credentialsId: 'github', poll: false, url: 'https://github.com/ajilraju/spring-boot-jsp.git'
            }
        }
        stage('Validate') {
            steps {
                sh 'mvn validate'
            }
        }
        stage('Test') {
            parallel {
                stage('Unit Test') {
                    steps {
                        sh 'mvn test'
                    }
                }
                stage('Integration Test') {
                    steps {
                        echo'Doing integration test'
                    }
                }
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Publishing Artifcats') {
            environment {
                SSH_KEY = credentials('web-pub')
            }
            when {
                expression { return params.PROD_BUILD }
            }
            steps {
                sh '''
                    version=$(perl -nle 'print "$1" if /<version>(v\\d+\\.\\d+\\.\\d+)<\\/version>/' pom.xml)
                    rsync -avzPe "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" target/news-${version}.jar ${SSH_USER}@${SERVER_IP}:/opt/artifactory/
                '''
            }
        }
    }
    post {
        success {
            slackSend color: "good", message: "The Build #${env.BUILD_NUMBER} is success: ${env.BUILD_URL}"
        }
        failure {
            slackSend color: "danger", message: "The Build #${env.BUILD_NUMBER} is failed: ${env.BUILD_URL}"
        }
    }
}
