node('jenkins_agent_node_1') {
   environment{
       registry = "pincher95/foaas"
       registryCredential = "dockerhub-pincher95"
       credentialsId = "secret-github"
   }
   def DockerImage = "foaas:v1.0"
   def customImage = null
   stage('Git') { // Get code from GitLab repository
     git branch: 'master',
       url: 'https://github.com/pincher95/MID-project.git'
   }

   stage('Build') { // Run the docker build
     customImage = docker.build "pincher95/foaas:${env.BUILD_NUMBER}"

   }
   stage('Run Tests') {
     sh "docker run --rm ${customImage.id} test"
   }

   stage('Deploy to K8s') { // Run tests on container
     kubernetesDeploy(configs: 'k8s/*', kubeconfigId: 'kube-config', textCredentials: [serverUrl: 'https://'])
   }
 }