pipeline {
  agent any

  triggers {
    issueCommentTrigger('.*test this please.*')
  }

  environment {
    SLACK_CHANNEL = '#opensource-cicd'
  }

  stages {

    stage ('Start') {
      steps {
        sendNotifications('STARTED', SLACK_CHANNEL)
      }
    }

    stage ('Building Docker Images') {
      steps {
        container('builder') {
          sh 'make image'
        }
      }
    }

    stage ('Running the tests') {
      steps {
        container('builder') {
          sh 'make test'
        }
      }
    }

    stage ('Pushing Docker Images') {
      when {
        branch 'master'
      }
      steps {
        container('builder') {
          script {
            sh 'make push-image'
          }
        }
      }
    }
  }

  post {
    success {
      sendNotifications('SUCCESS', SLACK_CHANNEL)
    }
    failure {
      sendNotifications('FAILED', SLACK_CHANNEL)
    }
  }
}
