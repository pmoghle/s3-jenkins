pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        BUCKET_NAME = 'your-bucket-name'
        WHITELISTED_IPS = ['1.2.3.4', '5.6.7.8']  // Add your whitelisted IPs here
    }
    
    stages {
        stage('Provision S3 Bucket') {
            steps {
                script {
                    withAWS(credentials: 'aws-credentials') {
                        def s3 = AmazonS3ClientBuilder.standard().withRegion('us-east-1').build()
                        
                        // Create the S3 bucket
                        if (!s3.doesBucketExistV2(BUCKET_NAME)) {
                            s3.createBucket(BUCKET_NAME)
                        }
                        
                        // Make the bucket private
                        s3.setBucketAcl(BUCKET_NAME, CannedAccessControlList.Private)
                        
                        // Enable bucket versioning
                        s3.setBucketVersioningConfiguration(new SetBucketVersioningConfigurationRequest(BUCKET_NAME, new BucketVersioningConfiguration(BucketVersioningConfiguration.ENABLED)))
                        
                        // Configure bucket CORS (optional)
                        s3.setBucketCrossOriginConfiguration(BUCKET_NAME, new BucketCrossOriginConfiguration())
                        
                        // Add IP-based bucket policy
                        def bucketPolicy = "{\"Version\":\"2012-10-17\",\"Id\":\"IPWhiteListPolicy\",\"Statement\":[{\"Sid\":\"IPWhiteList\",\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::${BUCKET_NAME}/*\",\"Condition\":{\"NotIpAddress\":{\"aws:SourceIp\":${getIpCondition()}}}}]}"
                        s3.setBucketPolicy(BUCKET_NAME, bucketPolicy)
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Clean up AWS credentials after the pipeline completes
                withAWS(region: 'us-east-1', credentials: 'aws-credentials') {
                    def awsCredentials = Jenkins.instance.getDescriptorByType(AmazonWebServicesCredentials.DescriptorImpl).getCredentials('aws-credentials').get(0)
                    def awsCredentialsId = awsCredentials.id
                    Jenkins.instance.getDescriptorByType(AmazonWebServicesCredentials.DescriptorImpl).getCredentials().removeAll { it.id == awsCredentialsId }
                    Jenkins.instance.save()
                }
            }
        }
    }
}

def getIpCondition() {
    def ipConditions = []
    WHITELISTED_IPS.each { ip ->
        ipConditions << "{\"aws:SourceIp\":\"${ip}\"}"
    }
    "[" + ipConditions.join(",") + "]"
}
