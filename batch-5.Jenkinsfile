pipeline {
    agent any

    tools {
        maven '3.8.4'
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
            steps {
                sh 'mvn test'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Copying Artifcats') {
            steps {
                sh '''
                    version=$(perl -nle 'print "$1" if /<version>(v\\d+\\.\\d+\\.\\d+)<\\/version>/' pom.xml)
                    rsync -avzP target/news-${version}.jar /opt/artifactory/
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
