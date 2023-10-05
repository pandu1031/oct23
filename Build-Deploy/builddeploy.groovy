//Declarative pipeline
 pipeline {
    agent {label 'slave1'} 
    parameters{
        string(name: 'BRANCH_NAME', defaultValue: '' , description: 'Enter the source code branch')
        string(name: 'SERVER_IP', defaultValue: '', description: 'Enter the server ip')
    }
     stages{
        stage("Clone code"){
            steps {
            println "here im cloning code from git hub"
            git branch: '$BRANCH_NAME',
                      url: 'https://github.com/pandu1031/boxfuse-sample-java-war-hello.git'
        }
        }
        stage("Build Step"){
            steps {
            println "Here im building code "
            sh "mvn clean package"
            sh "ls -l target"
            }
           }
           stage("uploading artifacts"){
            steps{
                println "here im uploading artifacts to s3 bucket"
                sh """
                aws s3 ls
                aws s3 ls s3://mammuu
                aws s3 cp target/hello-${BUILD_NUMBER}.war s3://mammuu/Pandu/${BRANCH_NAME}/${BUILD_NUMBER}
            """
            }
           }
           stage("Deploy Step"){
            steps{
                println "Deploying artifacts from jenkins to tomcat server"
                sh "whoami"
                sh "hostname -i"
                sh "ls -l /tmp/devops23.pem"
                sh "scp -o StrictHostKeyChecking=no -i /tmp/devops23.pem target/hello-${BUILD_NUMBER}.war ec2-user@${SERVER_IP}:/var/lib/tomcat/webapps/"
            }
        }
     }
 }