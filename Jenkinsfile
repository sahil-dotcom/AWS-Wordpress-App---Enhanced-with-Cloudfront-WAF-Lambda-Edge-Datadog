pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/sahil-dotcom/AWS-Wordpress-App---Enhanced-with-Cloudfront-WAF-Lambda-Edge-Datadog.git'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                cleanWs()
                git branch: 'uat', url: "${env.REPO_URL}"
            }
        }

        stage('Security Scans & Validation') {
            steps {
                script {
                    echo 'Running terraform format check...'
                    if (sh(script: 'terraform fmt -recursive', returnStatus: true) != 0) {
                        error 'Terraform format failed.'
                    }

                    echo 'Running terraform validate...'
                    if (sh(script: 'terraform validate', returnStatus: true) != 0) {
                        error 'Terraform validation failed. Please fix the syntax errors.'
                    }

                    echo 'Running checkov security scan...'
                    def checkovExitCode = sh(script: 'checkov -d . --output json > checkov_results.json', returnStatus: true)
                    archiveArtifacts artifacts: 'checkov_results.json'
                    if (checkovExitCode != 0) {
                        echo 'Checkov found potential security issues. Review checkov_results.json'
                        // Optionally fail the build
                        // error 'Security scan failed.'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'tf-user',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh 'terraform init -input=false'
                        sh 'terraform plan -out=tfplan'
                        archiveArtifacts artifacts: 'tfplan'
                        def planText = sh(script: 'terraform show -no-color tfplan', returnStdout: true)
                        echo "Terraform Plan Output:\n${planText}"
                    }
                }
            }
        }

        stage('Manual Approval') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Review the Terraform plan above. Approve to proceed with apply?', ok: 'Approve'
                }

                sh '''
                    git config user.name "sahil-dotcom"
                    git config user.email "rahatesahil47@gmail.com"
                    git fetch origin
                    git checkout main
                    git pull origin main
                    git merge --no-ff uat -m "Merge uat into main by Jenkins"
                    git push origin main
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    lock(resource: 'terraform-apply-lock') {
                        retry(2) {
                            withCredentials([aws(
                                credentialsId: 'tf-user',
                                accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                            )]) {
                                // Apply DNS changes first with verification
                                echo 'Applying Route53 DNS changes...'
                                sh """
                                    terraform apply -input=false \
                                        -target=module.dns.aws_route53_zone.dev \
                                        -auto-approve
                                """
                                
                                // Verify DNS changes propagated
                                timeout(time: 2, unit: 'MINUTES') {
                                    waitUntil {
                                        def ready = sh(
                                            script: 'terraform state show module.dns.aws_route53_zone.dev | grep -q "name_servers"',
                                            returnStatus: true
                                        ) == 0
                                        return ready
                                    }
                                }

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
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded! Infrastructure deployed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}