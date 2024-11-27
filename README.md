This project will create an EKS Kubernetes Cluster using Terraform

terraform init
terraform plan
terraform apply 

If there are no errors, then do the following to use kubectl commands from local terminal:
aws eks update-kubeconfig --region us-east-2 --name pc-k8-cluster

Credits: Most of the terraform files were copied and modified from: https://www.youtube.com/watch?v=LZssMfdJSeM&t=1241s
