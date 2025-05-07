pipeline {
    agent any
    
    environment {
        REPO_URL = 'https://github.com/sahil-dotcom/AWS-Wordpress-App---Enhanced-with-Cloudfront-WAF-Lambda-Edge-Datadog.git'
        WORKING_DIR = 'terraform-aws-infra'
    }
    
    stages {
        stage('Checkout Source Code') {
            steps {
                cleanWs()
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'uat']],
                    userRemoteConfigs: [[
                        url: env.REPO_URL
                    ]]
                ])
            }
        }
        
        stage('Security Scans & Validation') {
            steps {
                script {
                    dir(env.WORKING_DIR) {
                        // Format check
                        echo 'Running terraform format check...'
                        def fmtOutput = sh script: 'terraform fmt -check -recursive', returnStatus: true
                        if (fmtOutput != 0) {
                            error 'Terraform format check failed. Please run "terraform fmt" to fix formatting issues.'
                        }
                        
                        // Syntax validation
                        echo 'Running terraform validate...'
                        def validateOutput = sh script: 'terraform validate', returnStatus: true
                        if (validateOutput != 0) {
                            error 'Terraform validation failed. Please fix the syntax errors.'
                        }
                        
                        // Security scanning
                        echo 'Running checkov security scan...'
                        def checkovExitCode = sh script: 'checkov -d . --output json > checkov_results.json', returnStatus: true
                        archiveArtifacts artifacts: 'checkov_results.json'
                        if (checkovExitCode != 0) {
                            echo 'Checkov found potential security issues. Review checkov_results.json'
                            // Consider making this fail the build if you want strict security
                        }
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                script {
                    dir(env.WORKING_DIR) {
                        withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: 'tf-user',
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]]) {
                            // Initialize Terraform if needed
                            sh 'terraform init -input=false'
                            
                            sh 'terraform plan -out=tfplan'
                            archiveArtifacts artifacts: 'tfplan'
                            def planText = sh script: 'terraform show -no-color tfplan', returnStdout: true
                            echo "Terraform Plan Output:\n${planText}"
                        }
                    }
                }
            }
        }
        
        stage('Manual Approval') {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        input message: 'Review the Terraform plan above. Approve to proceed with apply?', 
                              ok: 'Approve'
                    }
                    
                    dir(env.WORKING_DIR) {
                        // Safer git operations
                        sh '''
                            git config --global user.name "Jenkins"
                            git config --global user.email "jenkins@example.com"
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
                    dir(env.WORKING_DIR) {
                        withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: 'tf-user',
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]]) {
                            // Apply DNS changes first if needed
                            sh 'terraform apply -input=false -target=module.dns.aws_route53_zone.dev -auto-approve'
                            sleep 120
                            
                            // Full apply
                            sh 'terraform apply -input=false tfplan'
                            def outputs = sh script: 'terraform output -json', returnStdout: true
                            echo "Terraform Outputs:\n${outputs}"
                            writeFile file: 'terraform_outputs.json', text: outputs
                            archiveArtifacts artifacts: 'terraform_outputs.json'
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