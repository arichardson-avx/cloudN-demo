provider "aws" {
  region  = var.region
  profile = var.profile
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "controller_VPC" {
  source = "./vpcSubnetsSg"

  aws_cidr_block     = "10.0.0.0/24"
  vpc_name           = "Shared-Services"
  vpc_IP             = 0 # 10.0.0.0/16
  vpc_cidr_offset    = 0
  subnet_cidr_offset = 2
  public_subnet_IPs  = [0, 1]
  private_subnet_IPs = []
  ssh_addresses      = var.ssh_addresses
  all_in_addresses   = []
  all_out_addresses  = ["0.0.0.0/0"]
  azs                = data.aws_availability_zones.available.names
}

# Don't run this module if IAM has already been setup in the account
module "aviatrix-iam-roles" {
  source = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-iam-roles?ref=terraform_0.12"
}

module "aviatrix-controller-build" {
  source            = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-build?ref=terraform_0.12"
  vpc               = module.controller_VPC.vpc_id
  subnet            = var.subnet_zone == "az1" ? module.controller_VPC.subnet_id_az1 : module.controller_VPC.subnet_id_az2
  keypair           = var.keypair
  ec2role           = module.aviatrix-iam-roles.aviatrix-role-ec2-name
  incoming_ssl_cidr = ["0.0.0.0/0"]
  name_prefix       = var.name_prefix
  type              = var.license_type
  instance_type     = "t3.xlarge"
}

data "aws_caller_identity" "current" {}

provider "aviatrix" {
  username      = "admin"
  password      = module.aviatrix-controller-build.private_ip
  controller_ip = module.aviatrix-controller-build.public_ip
}

module "aviatrix-controller-initialize" {
  source              = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-initialize?ref=terraform_0.12"
  admin_password      = var.admin_password
  admin_email         = var.admin_email
  private_ip          = module.aviatrix-controller-build.private_ip
  public_ip           = module.aviatrix-controller-build.public_ip
  access_account_name = var.access_account_name
  aws_account_id      = data.aws_caller_identity.current.account_id
  vpc_id              = module.aviatrix-controller-build.vpc_id
  subnet_id           = module.aviatrix-controller-build.subnet_id
  customer_license_id = var.customer_license_id
  name_prefix         = var.name_prefix
}

resource "tls_private_key" "avtx_key" {
  count = var.create_key ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 2048

  provisioner "local-exec" {
    command = "echo 'echo \"${tls_private_key.avtx_key[0].private_key_pem}\" > /home/ubuntu/.ssh/cloudN_demo.pem' | tee -a ../avtx-cloud/ubuntu_bootstrap ../avtx-cloud/iperf/iperf_client ../avtx-cloud/iperf/iperf_server"
  }

  provisioner "local-exec" {
    command = "echo 'chmod 400 /home/ubuntu/.ssh/cloudN_demo.pem' | tee -a ../avtx-cloud/ubuntu_bootstrap ../avtx-cloud/iperf/iperf_client ../avtx-cloud/iperf/iperf_server"
  }

  provisioner "local-exec" {
    command = "echo 'chown ubuntu /home/ubuntu/.ssh/cloudN_demo.pem' | tee -a ../avtx-cloud/ubuntu_bootstrap ../avtx-cloud/iperf/iperf_client ../avtx-cloud/iperf/iperf_server"
  }
}

resource "local_file" "avtx_priv_key" {
  count = var.create_key ? 1 : 0

  content         = tls_private_key.avtx_key[0].private_key_pem
  filename        = "../cloudN_demo_priv.pem"
  file_permission = "0400"
}

resource "local_file" "avtx_pub_key" {
  count = var.create_key ? 1 : 0

  content         = tls_private_key.avtx_key[0].public_key_openssh
  filename        = "../cloudN_demo_pub.pem"
  file_permission = "0666"
}

resource "aws_key_pair" "ec2_key" {
  count = var.create_key ? 1 : 0

  key_name   = "cloudN-demo"
  public_key = tls_private_key.avtx_key[0].public_key_openssh
}
