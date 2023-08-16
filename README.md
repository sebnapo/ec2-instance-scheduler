# EC2 instance scheduler

This repository allows you to deploy an API Gateway and 3 lambdas functions. 
It will allow you to schedule starting and stopping of EC2 instances through API calls.

You will need to have setup the aws cli with the account you want to deploy into.
Terraform is also needed to deploy everything.
By default, everything will be deployed in eu-west-1. If you want to change the behaviour, you have the region variable to change as well as the provider region also. 


## Command needed

* `./local_package.sh`                                          Create the required package for the lambda function deployment => this one might need you to edit it manually, especially the second line.
* `cd tf`                                                       Change current directory to tf
* `terraform init`                                              Initialize the repository with terraform
* `terraform apply --var-file=tfvars/no-prod.tfvars`            Deploy the application with terraform
* `terraform apply --var-file=tfvars/no-prod.tfvars --destroy`  Destroy the application

Go into API Gateway service, retrieve the url from the created stage and then, you can call the route /provision with the parameter that follows : 

* start_time (timezone-less datetime): The date and time when the specified action should start for the EC2 instance, without considering timezones.
* end_time (timezone-less datetime): The date and time when the specified action should end for the EC2 instance, without accounting for timezones.
* instance_id (EC2 instance identifier): The unique identifier assigned to the EC2 instance.