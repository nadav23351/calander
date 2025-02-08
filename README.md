
terraform init  

terraform init -upgrade  

terraform apply -var-file="secret.tfvars"  

terraform destroy -var-file="secret.tfvars"  

1. create a secret.tfvars file in each directory aws and aws_cluster_resources so that can be used for running terraform
2. first run terraform init in `aws` directory and run following commands
```bash
cd aws
terraform init
terraform apply -var-file="secret.tfvars"  
```

3. now go to aws_cluster_resource directory and run the following command
```bash
cd aws_cluster_resources
terraform init
terraform apply -var-file="secret.tfvars"  
```

4. now go to argo_resources directory adn run following
```bash
cd argo_resources
terraform init
terraform apply -var-file="secret.tfvars"  

```

5. config your aws cli with following command and kubectl context
```bash
aws configure set aws_access_key_id ""
aws configure set aws_secret_access_key ""
aws configure set default.region us-east-1
aws eks --region us-east-1 update-kubeconfig --name staging
```


6. get ips and place them in under dns record in cloudflare

> `kubectl get svc`  
copy the external ip and run nslookup on it.  
> `nslookup a7e168cad39aa423dbb210a39873d0ec-03e8ccb46fb6a2d4.elb.us-east-1.amazonaws.com`  

