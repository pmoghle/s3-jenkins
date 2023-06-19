pipeline {
    agent any
    
    stages {
        stage('Provision S3 Bucket') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh 'terraform init'
                    
                    // Generate a random bucket name
                    def bucketName = "my-private-bucket-${UUID.randomUUID().toString()}"
                    
                    // Whitelisted IP addresses
                    def whitelistedIps = ['1.2.3.4', '5.6.7.8']  // Add your whitelisted IPs here
                    
                    sh "terraform apply -auto-approve -var='bucket_name=${bucketName}' -var='whitelisted_ips=${whitelistedIps.join(',')}'"
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Clean up AWS credentials after the pipeline completes
                deleteCredentials([
                    'aws-access-key-id',
                    'aws-secret-access-key'
                ])
            }
        }
    }
}
