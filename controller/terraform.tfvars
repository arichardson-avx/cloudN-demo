region              = "us-west-1"
profile             =                   # AWS profile configured in aws-cli
vpc_name            = "Shared-Services"
subnet_zone         = "az1"
create_key          = true              # Provide existing key name below if set to false
keypair             = "cloudN-demo"
license_type        = "BYOL" # Valid values are "meteredplatinum" and "BYOL"
access_account_name = "cloudN-demo"     # Name used to onboard AWS account in the Aviatrix controller
admin_email         = "arichardson@aviatrix.com"                
admin_password      = "JesusIsKing!"                  # Controller password
customer_license_id = "avx-dev-1613002716.89"                # Provide license if BYOL selected
name_prefix         = "AlishaCloudN"                # Use it if there is already a controller deployed in the AWS account

