pipeline {
    agent any

        triggers {
        githubPush()  // GitHub webhook
    }

    environment {
        AWS_REGION = 'ap-southeast-2'  
        AWS_CREDENTIALS_ID = 'AWS_CREDENTIALS_ID'
}

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/ABlackPenny/HelloWorldExercise.git',
                     branch: 'master',
                     credentialsId: 'github-credentials-id'
                      poll: false
            }
        }

       
        stage('Terraform Init') {
            steps {
                withAWS(credentials: env.AWS_CREDENTIALS_ID, region: env.AWS_REGION) {
                    sh 'terraform init -input=false'
                }
            }
        }


         stage('Terraform Plan') {
            steps {
                withAWS(credentials: env.AWS_CREDENTIALS_ID) {
                    sh 'terraform plan -out=tfplan -var "region=${AWS_REGION}"'
                    stash name: 'tfplan', includes: 'tfplan'
                }
            }
        }


        stage('Manual Approval') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: """Approve deployment to AWS?
                    Region: ${AWS_REGION}""",
                    ok: 'Deploy',
                    submitterParameter: 'approver'
                }
            }
        }
 
        stage('Terraform Apply') {
            steps {
                withAWS(credentials: env.AWS_CREDENTIALS_ID) {
                    unstash 'tfplan'
                    sh 'terraform apply -auto-approve tfplan'
                    
                    script {
                        def alb_dns = sh(script: 'terraform output -raw alb_dns_name', returnStdout: true).trim()
                        echo """
                        ## Deployment Successful! 
                        **Application URL**: http://${alb_dns}
                        **Approved by**: ${env.approver}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}