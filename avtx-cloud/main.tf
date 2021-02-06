provider "aviatrix" {
  username      = var.username
  password      = var.password
  controller_ip = var.controller_ip
}


data "template_file" "ubuntu_server" {
  template = file("${path.cwd}/ubuntu_bootstrap")

  depends_on = [tls_private_key.avtx_key]
}

resource "tls_private_key" "avtx_key" {
  count = var.create_key ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 2048

  provisioner "local-exec" {
    command = "echo 'echo \"${tls_private_key.avtx_key[0].private_key_pem}\" > /home/ubuntu/.ssh/cloudN_demo.pem' | tee -a ./ubuntu_bootstrap ./iperf/iperf_client ./iperf/iperf_server"
  }

  provisioner "local-exec" {
    command = "echo 'chmod 400 /home/ubuntu/.ssh/cloudN_demo.pem' | tee -a ./ubuntu_bootstrap ./iperf/iperf_client ./iperf/iperf_server"
  }

  provisioner "local-exec" {
    command = "echo 'chown ubuntu /home/ubuntu/.ssh/cloudN_demo.pem' | tee -a ./ubuntu_bootstrap ./iperf/iperf_client ./iperf/iperf_server"
  }
}

resource "local_file" "avtx_priv_key" {
  count = var.create_key ? 1 : 0

  content         = tls_private_key.avtx_key[0].private_key_pem
  filename        = "./cloudN_demo_priv.pem"
  file_permission = "0400"
}

resource "local_file" "avtx_pub_key" {
  count = var.create_key ? 1 : 0

  content         = tls_private_key.avtx_key[0].public_key_openssh
  filename        = "./cloudN_demo_pub.pem"
  file_permission = "0666"
}

resource "aws_key_pair" "ec2_key" {
  count    = var.create_key ? 1 : 0
  provider = aws.region_1

  key_name   = var.key_name
  public_key = tls_private_key.avtx_key[0].public_key_openssh
}

resource "aws_key_pair" "ec2_key_imported" {
  count    = var.create_key ? 0 : 1
  provider = aws.region_1

  key_name   = var.key_name
  public_key = file("../cloudN_demo_pub.pem")
}
