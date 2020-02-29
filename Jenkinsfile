node('agent-node-label') {

  def DockerImage = "foaas:v1.0"
  def customImage = null
  stage('Git') { // Get code from GitLab repository
    git branch: 'master',
      url: 'https://github.com/pincher95/foaas.git'
  }

  stage('Build') { // Run the docker build
    customImage = docker.build "pincher95/foaas:${env.BUILD_NUMBER}"

  }
//   stage('Run Tests') {
//       sh '''
//           docker run --rm -d -p 5000:5000 --name test ${customImage.id}
//           while true; do
//             http_hb=$(curl -s -o /dev/null -w "%{http_code}" 'http://localhost:8000')
//             if [ $http_hb -eq 200 ]; then
//               exit 0
//               break
//             elif [ $sleep -lt 60 ]; then
//               sleep=$((sleep+1))
//               continue
//             else
//               exit 1
//               break
//             fi
//             done
//       '''
//   }
  stage('Push to Docker Hub') { // Run the built image
    withDockerRegistry(credentialsId: 'dockerhub.pincher95',url: 'https://index.docker.io/v1/') {
        customImage.push()
    }
  }
  stage('Deploy to K8s') { // Run tests on container
    kubernetesDeploy(configs: 'k8s/*', kubeconfigId: 'c67ba43e-0d15-4225-8fd1-8aed0fa10659', textCredentials: [serverUrl: 'https://'])
  }
}