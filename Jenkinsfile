node('jenkins_micro_aws_slave') {

  def DockerImage = "foaas:v1.0"
  def customImage = null
  stage('Git') { // Get code from GitLab repository
    git branch: 'master',
      url: 'https://github.com/pincher95/foaas.git'
  }

  stage('Build') { // Run the docker build
    customImage = docker.build "pincher95/foaas:${env.BUILD_NUMBER}"

  }
  stage('Run Tests') {
    sh "docker run --rm ${customImage.id}"
  }
  stage('Push to Docker Hub') { // Run the built image
    withDockerRegistry(credentialsId: 'pincher95') {
        customImage.push()
    }
  }
  stage('Deploy to K8s') { // Run tests on container
    kubernetesDeploy(configs: 'k8s/*', kubeconfigId: 'kube-config', textCredentials: [serverUrl: 'https://'])
  }
}