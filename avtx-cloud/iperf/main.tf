data "template_file" "iperf_client" {
  template = file("${path.cwd}/iperf/iperf_client")
}

data "template_file" "iperf_server" {
  template = file("${path.cwd}/iperf/iperf_server")
}

data "aws_ami" "ubuntu_server" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_eip" "iperf_client_a_eip" {
  count = var.create_clients ? var.instance_number : 0

  vpc = true
  tags = {
    Name = "iperf-client-A-${count.index}"
  }
}

resource "aws_eip" "iperf_client_b_eip" {
  count = var.create_clients ? var.instance_number : 0

  vpc = true
  tags = {
    Name = "iperf-client-B-${count.index}"
  }
}

resource "aws_instance" "iperf_client_a" {
  count = var.create_clients ? var.instance_number : 0

  key_name                    = var.key_name
  ami                         = var.ami == "" ? data.aws_ami.ubuntu_server.id : var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.clients_subnet_id_1
  vpc_security_group_ids      = [var.clients_sg_id]
  associate_public_ip_address = true
  user_data                   = data.template_file.iperf_client.template

  tags = {
    Name = "iperf-client-A-${count.index}"
  }
}

resource "aws_instance" "iperf_client_b" {
  #count = var.clients_subnet_id_2 == "" ? 0 : var.instance_number
  count = var.create_clients ? var.instance_number : 0

  key_name                    = var.key_name
  ami                         = var.ami == "" ? data.aws_ami.ubuntu_server.id : var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.clients_subnet_id_2
  vpc_security_group_ids      = [var.clients_sg_id]
  associate_public_ip_address = true
  user_data                   = data.template_file.iperf_client.template

  tags = {
    Name = "iperf-client-B-${count.index}"
  }
}

resource "aws_eip_association" "eip_assoc_a" {
  count = var.create_clients ? var.instance_number : 0

  network_interface_id = aws_instance.iperf_client_a[count.index].primary_network_interface_id
  allocation_id        = aws_eip.iperf_client_a_eip[count.index].id
}

resource "aws_eip_association" "eip_assoc_b" {
  count = var.create_clients ? var.instance_number : 0

  network_interface_id = aws_instance.iperf_client_b[count.index].primary_network_interface_id
  allocation_id        = aws_eip.iperf_client_b_eip[count.index].id
}


resource "aws_instance" "iperf_server_a" {
  count = var.create_servers ? var.instance_number : 0

  key_name                    = var.key_name
  ami                         = var.ami == "" ? data.aws_ami.ubuntu_server.id : var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.servers_subnet_id_1
  vpc_security_group_ids      = [var.servers_sg_id]
  associate_public_ip_address = true
  user_data                   = data.template_file.iperf_server.template
  private_ip                  = var.fixed_private_ip ? join("", [regex("([\\d+\\.]+)(\\.\\d+/\\d+)", var.servers_subnet_cidr_1)[0], ".", var.private_ip_az_1 + count.index]) : null

  tags = {
    Name = "iperf-server-A-${count.index}"
  }
}

resource "aws_instance" "iperf_server_b" {
  #count = var.servers_subnet_id_2 == "" ? 0 : var.instance_number
  count = var.create_servers ? var.instance_number : 0

  key_name                    = var.key_name
  ami                         = var.ami == "" ? data.aws_ami.ubuntu_server.id : var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.servers_subnet_id_2
  vpc_security_group_ids      = [var.servers_sg_id]
  associate_public_ip_address = true
  user_data                   = data.template_file.iperf_server.template
  private_ip                  = var.fixed_private_ip ? join("", [regex("([\\d+\\.]+)(\\.\\d+/\\d+)", var.servers_subnet_cidr_2)[0], ".", var.private_ip_az_2 + count.index]) : null

  tags = {
    Name = "iperf-server-B-${count.index}"
  }
}
