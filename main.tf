resource "aws_vpc" "myvpc" {
  cidr_block = var.network_info.vpccidr
  tags = {
    Name = var.network_info.vpcname
  }
}

resource "aws_subnet" "pubsubnet" {
  count             = length(var.network_info.pubsub[0].pubcidr)
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.network_info.pubsub[0].pubcidr[count.index]
  availability_zone = var.network_info.pubsub[0].pubaz[count.index]
  tags = {
    Name = var.network_info.pubsub[0].pubname[count.index]
  }
}

resource "aws_subnet" "prsubnet" {
  count             = length(var.network_info.prsub[0].prcidr)
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.network_info.prsub[0].prcidr[count.index]
  availability_zone = var.network_info.prsub[0].praz[count.index]
  tags = {
    Name = var.network_info.prsub[0].prname[count.index]
  }
}

resource "aws_route_table" "pubroute" {
  count  = length(var.network_info.pubsub[0].pubcidr)
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    Name = "my_pub_route_table"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "internet_gateway"
  }
}
resource "aws_route_table_association" "pub_association" {
  count          = length(var.network_info.pubsub[0].pubcidr)
  subnet_id      = aws_subnet.pubsubnet[count.index].id
  route_table_id = aws_route_table.pubroute[count.index].id
}
/*
resource "aws_route_table" "prroute" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.myngw[0].id
  }
  tags = {
    Name = "my_pr_route_table"
  }
}

resource "aws_nat_gateway" "myngw" {
  connectivity_type = "private"
  count             = length(var.network_info.prsub[0].prcidr)
  subnet_id         = aws_subnet.prsubnet[0].id
  tags = {
    Name = "nat_gateway"
  }
}

resource "aws_route_table_association" "pr_association" {
  count          = length(var.network_info.prsub[0].prcidr)
  subnet_id      = aws_subnet.prsubnet[count.index].id
  route_table_id = aws_route_table.prroute.id
}
*/

resource "aws_security_group" "mysg" {
  description = "this is my security group"
  name        = "my_security_group"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]


    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "prov_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "my-first-keypair"
  subnet_id = aws_subnet.pubsubnet[0].id
  vpc_security_group_ids = [aws_security_group.mysg.id]
  tags = {
    Name = "provisinor_instance"
  }
}

resource "null_resource" "remote_prov" {
triggers = {
  build_no="1.4"
}
connection {
  type = "ssh"
  host = aws_instance.prov_instance.public_ip
  user = "ubuntu"
  private_key = file("C:/Users/shara/Downloads/adilfirstkey.pem")
}

provisioner "file" {
  source = "html.sh"
  destination = "/tmp/html.sh"
}
provisioner "remote-exec" {
  inline = [ "sudo chmod +x /tmp/html.sh", "sh /tmp/html.sh"]
}
}