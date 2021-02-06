# Azure & AWS infrastructure for the cloudN demo

### Summary

This TF will build the cloud infrastructure for the cloudN demo. See jpgs for details.\
You can deploy AWS, Azure or both at the same time

### Shared configuration
#### Before running TF:
1. Fill in the controller IP and access credentials in the ***terraform.tfvars***
2. Provide the key name to be used for the deployed EC2s/VMs. It will be "cloudN-demo" if you created the key via the controller TF\
   I recommend you set ***create_key=true*** if you use existing controller. The key will be uploaded automatically to all instances and saved in the local folder.
3. Provide IP addresses allowed to access the demo from the Internet in ***ssh_addresses***. You can use ***0.0.0.0/0*** for open access  

### AWS deployment
#### Before running TF:
1. Delete azure.auto.tfvars, azure.tf, azure.variables.tf, azure_outputs.tf files and azure_* folders
2. Fill in the following info into the ***aws.auto.tfvars*** file:
   - aws_account_name - name onboarded in the controller. "cloudN-demo" if controller deployed via provided TF
   - aws_profile - configured for the aws cli
   - ***optional*** if ***create_key=true*** set create_private_ec2 & create_public_ec2 to ***false***
   - leave ***create_VIF*** set to ***false***

#### Build the infrastructure
3. Run `terraform apply`
4. ***optional*** Set create_private_ec2 & create_public_ec2 to ***true*** 
5. ***optional*** Run `terraform apply`

#### Bring up DX connectivity
6. Provide Piotr with the AWS account number
7. Accept the connection in AWS, copy the following to the ***aws.auto.tfvars*** file
   - ***connection ID***  (Check "Direct Connect -> connections")
   - ***aws_vlan***       (Check "Direct Connect -> connections")
8. Change ***create_VIF*** to true in the ***aws.auto.tfvars*** file
9. Run `terraform apply`

### Azure deployment
#### Before running TF:
1. Delete aws.auto.tfvars, aws.tf, aws.variables.tf files and aws_* folders
2. Create Aviatrix app in Azure (see Azure onboarding documentation)
3. Fill in the following info into the ***azure.auto.tfvars*** file:
   - ***azure_account_name*** - name to be displayed in the controller. TF will onboard the Azure subscribtion into the controller
   - ***azure_subscription_id,arm_directory_id,arm_application_id, arm_application_key*** (see Azure onboarding documentation)
   - leave ***create_peering*** set to ***false***

#### Build the infrastructure
4. Run `terraform apply`
5. Send ***express_route_service_key*** to Piotr

#### Bring up ER connectivity
6. Change ***create_peering*** to true in the ***azure.auto.tfvars*** file
9. Run `terraform apply`
