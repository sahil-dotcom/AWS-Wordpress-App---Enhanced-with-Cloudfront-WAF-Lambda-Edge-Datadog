pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/sahil-dotcom/AWS-Wordpress-App---Enhanced-with-Cloudfront-WAF-Lambda-Edge-Datadog.git'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                cleanWs()
                git branch: 'uat', 
                url: "${env.REPO_URL}"
            }
        }

        stage('Backend configuration') {
            steps {
                script {
                    withCredentials([
                        aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                            credentialsId: 'tf-user', 
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        echo 'Setting up Terraform backend...'
                        dir ('backend') {
                            try {
                                sh '''
                                terraform init -input=false
                                terraform fmt
                                terraform validate
                                terraform apply -auto-approve
                                '''
                            } catch (Exception e) {
                                error ("Failed to initalize backend: ${e.getMessage()}")
                            }
                        }
                        echo 'Initalizing main Terraform configuration...'
                        try {
                            sh '''
                            terraform init -input=false
                            terraform fmt -recursive
                            '''
                        } catch (Exception e) {
                            error ("Failed to initalize main configuration: ${e.getMessage()}")
                        }
                    }
                }
            }
        }

        stage('Security Scans & Validation') {
            steps {
                script {
                    echo 'Running validation scan...'
                    def validateOutput = sh(
                        script: 'terraform validate', 
                        returnStatus:true
                        )

                    if (validateOutput != 0){
                        echo 'Terraform validation failed. Please fix the syntax errors.'
                    }

                    echo 'Running checkov security scan...'
                    def checkovExitCode = sh(
                        script: 'checkov -d . --output json > checkov_results.json', 
                        returnStatus: true
                        )
                    archiveArtifacts artifacts: 'checkov_results.json'
                    if (checkovExitCode != 0) {
                        echo 'Checkov found potential security issues. Review checkov_results.json'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    withCredentials([
                        aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        credentialsId: 'tf-user', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        echo 'Genrating tfplan...'
                        def planStatus = sh(
                            script:'terraform plan -detailed-exitcode -out=tfplan',
                            returnStatus: true
                        )

                        if (planStatus == 1) {
                            error ('Terraform plan failed')
                        }
                        def planText = sh(
                            script: 'terraform show -no-color tfplan',
                            returnStdout: true
                        ).trim()
                        writeFile file: 'terraform_plan.txt', text: planText
                        archiveArtifacts artifacts: 'tfplan'
                    }
                }
            }
        }

        stage('Manual Approval') {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                       input {
                            message 'Review the Terraform plan above. Approve to proceed with apply?'
                            ok 'Approve'
                        }
                    }
                    withCredentials([
                        gitUsernamePassword(
                            credentialsId: 'Github_token', 
                            gitToolName: 'Default')
                    ]) {
                        sh '''
                            git config user.name "sahil-dotcom"
                            git config user.email "rahatesahil47@gmail.com"
                            git remote set-url origin https://${GIT_USER}:${GIT_TOKEN}@github.com/sahil-dotcom/AWS-Wordpress-App---Enhanced-with-Cloudfront-WAF-Lambda-Edge-Datadog.git
                            git fetch origin
                            git checkout main
                            git pull origin main
                            git merge --no-ff uat -m "Merge uat into main by Jenkins"
                            git push origin main
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    lock(resource: 'terraform-apply-lock') {
                        retry(2) {
                            withCredentials([
                                aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                credentialsId: 'tf-user', 
                                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')
                            ]) {
                                // Apply DNS changes first with verification
                                echo 'Applying Route53 DNS changes...'
                                sh '''
                                    terraform apply -input=false \
                                        -target=module.dns.aws_route53_zone.dev \
                                        -auto-approve
                                '''
                                def nameServers = sh(
                                    script: 'terraform state show module.dns.aws_route53_zone.dev',
                                    returnStdout: true
                                ).trim()
                                echo "Name servers to update: ${nameServers}"

                                input message: "Please update your domain's name servers in Hostinger",
                                    ok: 'Continue'
                                    

                                // Apply full configuration
                                echo 'Applying full Terraform changes...'
                                sh 'terraform apply -input=false tfplan'

                                // Capture and store outputs
                                def outputs = sh(
                                    script: 'terraform output -json',
                                    returnStdout: true
                                ).trim()
                                
                                echo "Terraform Outputs:\n${outputs}"
                                writeJSON file: 'terraform_outputs.json', json: outputs
                                archiveArtifacts artifacts: 'terraform_outputs.json'
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed - cleaning up workspace'
            // cleanWs()
        }
        success {
            echo 'Pipeline succeeded! Infrastructure deployed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}