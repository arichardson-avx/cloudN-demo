# cloudN demo in Azure & AWS

### Summary

This TF will build the cloud infrastructure for the cloudN demo. See jpgs for details.\
Code has been tested with terraform version 0.13

### Controller deployment
This step is optional. You can use existing cotroller as well.\
If you decide to deploy the controller, I recommend you let TF create a key by leaving ***create_key = true*** in the ***terraform.tfvars***\
The controller state will be kept in a different TF state file than the Aviatrix MCNA. See ***README*** in the controller folder for more details.

### Transit & spokes deployment

AWS and Azure cloud infrastructure will be kept in a different TF state than the controller.\
See ***README*** in avtx-cloud folder for the deployment details.
