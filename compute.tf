data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}


resource "random_id" "ec2_node_random" {
  byte_length = 2
  count       = var.count_t2
}


resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "ec2" {
  count                  = var.count_t2
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.auth.id
  instance_type          = var.t2_instance_type
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id              = element(aws_subnet.public_subnet[*].id, count.index)
  # subnet_id = aws_subnet.public_subnet[count.index].id
  root_block_device {
    volume_size = var.vol_size_t2
  }

  tags = {
    Name = "t2_micro_ec2-${random_id.ec2_node_random[count.index].dec}"
  }

  # provisioner "local-exec" {
  #   command = "echo ${self.public_ip} >> aws_hosts" # && aws ec2 wait instance-status-ok --instance-ids ${self.id} --region us-east-1"
  # }

  # provisioner "local-exec" {
  #   when    = destroy
  #   command = "sed -i '1!d' aws_hosts"
  # } Commented (Starting both local-exec provisioners from a jenkins script)


}

# resource "null_resource" "ansible_start" {
#   depends_on = [aws_instance.ec2]
#   provisioner "local-exec" {
#     command = "ansible-playbook playbooks/ansible_ec2.yml"
#   }
# } Commented (Ansible is start from jenkins plugin now)

output "instances_ip" {
 value = [for i in aws_instance.ec2[*]: i.public_ip]
}

output "instances_id" {
  value = [for i in aws_instance.ec2[*]: i.id]
}