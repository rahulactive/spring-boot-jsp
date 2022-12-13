pipeline {
    agent any

    tools {
        maven '3.8.1'
    }
    parameters {
        booleanParam(name: 'PROD_BUILD', defaultValue: true, description: 'Enble this as a production build')
        string(name: 'SERVER_IP', defaultValue: '127.0.0.1', description: 'Provide production server IP Address.')
    }

    stages {
        stage('Source') {
            steps {
                git branch: 'batch8', changelog: false, credentialsId: 'github', poll: false, url: 'https://github.com/ajilraju/spring-boot-jsp.git'
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
                        echo'Doing integration test' // Just for demostration of the parallel job.
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
            when {
                        expression { return params.PROD_BUILD }
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'deploy-java-ssh-key', keyFileVariable: 'SSHKEY', usernameVariable: 'SSHUSER')]) {
                    sh '''
                        version=$(perl -nle 'print "$1" if /<version>(v\\d+\\.\\d+\\.\\d+)<\\/version>/' pom.xml)
                        rsync -avzPe "ssh -i ${SSHKEY} -o StrictHostKeyChecking=no" target/news-${version}.jar ${SSHUSER}@${SERVER_IP}:/home/deploy/java-app/
                        ssh -o StrictHostKeyChecking=no -i ${SSHKEY} ${SSHUSER}@${SERVER_IP} sudo /usr/bin/systemctl restart java-app.service
                    '''
                }
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
