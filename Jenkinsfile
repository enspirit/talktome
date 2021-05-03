pipeline {
  agent any

  triggers {
    issueCommentTrigger('.*test this please.*')
  }

  environment {
    VERSION = get_docker_tag()
    SLACK_CHANNEL = '#opensource-cicd'
    DOCKER_REGISTRY = 'docker.io'
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

    stage ('Pushing Docker Main Version Image') {
      when {
        anyOf {
          branch 'master'
          buildingTag()
        }
      }
      steps {
        container('builder') {
          script {
            docker.withRegistry('', 'dockerhub-credentials') {
              sh 'make push-image'
            }
          }
        }
      }
    }

    stage ('Pushing Docker Tag Images') {
      when {
        buildingTag()
      }
      steps {
        container('builder') {
          script {
            docker.withRegistry('', 'dockerhub-credentials') {
              sh 'make push-tags'
            }
          }
        }
      }
    }

    stage ('Publish to rubygems.org') {
      environment {
        GEM_HOST_API_KEY = credentials('jenkins-rubygems-api-key')
      }
      when {
        buildingTag()
      }
      steps {
        container('builder') {
          script {
            sh 'make gem.publish'
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

def get_docker_tag() {
  if (env.TAG_NAME != null) {
    return env.TAG_NAME
  }
  return 'latest'
}
