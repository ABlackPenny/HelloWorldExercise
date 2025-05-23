pipeline {
    agent any

    triggers {
        pollSCM('*/5 * * * *') 
    }

    environment {
        AWS_REGION = 'ap-southeast-2'  
        AWS_CREDENTIALS_ID = 'AWS_CREDENTIALS_ID'
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/ABlackPenny/HelloWorldExercise.git',
                        credentialsId: 'github-credentials-id'
                    ]]
                ])
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDENTIALS_ID,
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    bat """
                    cd aws-config
                    set AWS_REGION=${AWS_REGION}
                    terraform init -input=false
                    """
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDENTIALS_ID
                ]]) {
                    bat """
                    cd aws-config
                    set AWS_REGION=${AWS_REGION}
                    terraform plan -out=tfplan
                    """
                    stash name: 'tfplan', includes: 'aws-config/tfplan'
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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDENTIALS_ID
                ]]) {
                    unstash 'tfplan'
                    bat """
                    cd aws-config
                    set AWS_REGION=${AWS_REGION}
                    terraform apply -auto-approve tfplan
                    """
                    script {
                        def alb_dns = bat(
                            script: 'cd aws-config && terraform output -raw alb_dns_name',
                            returnStdout: true
                        ).trim()
                        echo """
                        ## Deployment Successful! 
                        **Application URL**: http://${alb_dns}
                        **Approved by**: ${env.approver}
                        """
                    }
                }
            }
        }

stage('Integration Test') {
  steps {
    bat """  // [!code ++]
      cd aws-config
      FOR /F "delims=" %%i IN ('terraform output -raw alb_dns_name') DO SET ALB_DNS_NAME=%%i
      curl -s -o nul -w "%%{http_code}" http://%ALB_DNS_NAME% | findstr "200" > nul
      IF %ERRORLEVEL% EQU 0 (
        echo Integration test passed: Application is responding with HTTP 200
      ) ELSE (
        echo Integration test failed: Application is not responding correctly.
        exit /b 1
      )
    """
  }
}

    }

    post {
        always {
            cleanWs()
        }
    }
}