# Final Project overview
Utilizing most tools like Terraform, Bash, Python and etc...
To deploy infrastructure to AWS and provision monitoring, logging, consul and simple application.
All provisioning will be done to EKS cluster.
This project is for learning purpose only and not for production purpose.  


# Requirements
- AWS account
- Git
- Python ~> 3.5
- AWS cli ~> 1.17.x
- Terraform ~> 0.12.x
- Helm ~> 3.x
- kubectl ~> 0.14.x

# Init steps
- Create AWS access key and AWS secret key.
- AWS "s3-backend-state" bucket for terraform state.

# Clone the project.
https://github.com/pincher95/OpsSchool-project.git

# Deploy and provision.
````
$ cd OpsSchool-project
$ ./initscript apply
````
Take a big breath make coffee it's will take some time.

# Access the Cluster
Access Prometheus, Grafana, Kibana, Consul, Jenkins services via ssh tunnel.
SSH bootstrap key to access the cluster created during infra deployment.
````
$ OpsSchool-project/infra/keys/project.pem
````
````
        -------------          -------------          -------------
-----> |   Bastion   | -----> |  SSH Tunnel | -----> | ESK Cluster | 
        -------------          -------------          ------------- 
````
# Destroy infra 
````
$ cd OpsSchool-project
$ ./initscript destroy
````