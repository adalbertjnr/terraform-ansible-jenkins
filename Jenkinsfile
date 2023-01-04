pipeline {
  agent any
  environment {
    TF_IN_AUTOMATION = 'true'
    TF_CLI_CONFIG_FILE = credentials('tf-creds')
    AWS_SHARED_CREDENTIALS_FILE = '/home/ubuntu/.aws/credentials'
  }
  
  stages {
    stage('Init') {
      steps {
        sh 'ls'
        sh 'cat $BRANCH_NAME.tfvars'
        sh 'terraform init -no-color'
      }
    }
    stage('Plan') {
      steps {
        sh 'terraform plan -no-color -var-file="$BRANCH_NAME.tfvars"'
      }
    }
    stage('Apply') {
      steps {
        sh 'terraform apply -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
      }
    }
    stage('EC2 Wait') {
      steps {
        sh 'aws ec2 wait instance-status-ok --region us-east-1'
      }
    }  
    stage('Ansible') {
      steps {
        ansiblePlaybook(credentialsId: 'ec2-ssh', inventory: 'aws_hosts', playbook: 'playbooks/ansible_ec2.yml') 
      }
    }
    stage('Validate Destroy') {
      input {
        message 'Do you want to destroy?'
        ok 'Destroy this plan'
      }
      steps {
        echo 'Accepted'
      }
    }
    stage('Destroy') {
      steps {
        sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
      }
    }
  }
  post {
    success {
      echo 'Success'
    }
    failure {
      sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
    }
  }
}