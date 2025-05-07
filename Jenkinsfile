pipeline {
    agent any
    
    // Environment variables that will be used throughout the pipeline
    environment {
        REPO_URL = 'https://github.com/sahil-dotcom/AWS-Wordpress-App---Enhanced-with-Cloudfront-WAF-Lambda-Edge-Datadog.git'
        WORKING_DIR = '/home/aws_builder/terraform-aws-infra'  // Directory where Terraform files are located
    }
    
    stages {
        stage('Checkout Source Code') {
            steps {
                script {
                    cleanWs()
                    git branch: 'uat', 
                         url: env.REPO_URL,
                    
                    dir(env.WORKING_DIR) {
                        sh 'terraform init'
                    }
                }
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
                        sh 'checkov -d . --output json > checkov_results.json'
                        archiveArtifacts artifacts: 'checkov_results.json'
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                script {
                    dir(env.WORKING_DIR) {
                        // Use the AWS credentials from Jenkins
                        withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: 'tf-user', // Replace with your Jenkins AWS credentials ID
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]]) {
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
                        sh '''
                            git config --global user.name "Jenkins"
                            git config --global user.email "jenkins@example.com"
                            git checkout main
                            git merge uat
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
                            credentialsId: 'your-aws-credentials-id', // Same as above
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]]) {
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