
resource "aws_instance" "jenkins" {
  ami                    = local.ami_id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = "subnet-04da01805c8d534b5" #replace your Subnet in default VPC

  # need more for terraform
  root_block_device {
    volume_size = 50
    volume_type = "gp3" # or "gp2", depending on your preference
  }
  user_data = file("jenkins.sh")
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-jenkins"
    }
  )
}

resource "aws_instance" "jenkins_agent" {
  ami                    = local.ami_id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = "subnet-04da01805c8d534b5" #replace your Subnet

  # need more for terraform
  root_block_device {
    volume_size = 50
    volume_type = "gp3" # or "gp2", depending on your preference
  }
  user_data = file("jenkins-agent.sh")
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-jenkins-agent"
    }
  )
}

# resource "aws_instance" "sonar" {
#   ami           = local.ami_id
#   instance_type = "t3.large"
#   vpc_security_group_ids = [aws_security_group.main.id]
#   subnet_id = "subnet-04da01805c8d534b5" #replace your Subnet in default VPC
#   # need more for terraform
#   root_block_device {
#     volume_size = 50
#     volume_type = "gp3" # or "gp2", depending on your preference
#   }
#    user_data = file("sonarqube.sh")
#   tags = merge(
#     local.common_tags,
#     {
#         Name = "${var.project_name}-${var.environment}-sonar"
#     }
#   )
# }

resource "aws_security_group" "main" {
  name        = "${var.project_name}-${var.environment}-jenkins"
  description = "Created to attatch Jenkins and its agents"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-jenkins"
    }
  )
}

resource "aws_route53_record" "jenkins" {
  zone_id         = var.zone_id
  name            = "jenkins.${var.zone_name}"
  type            = "A"
  ttl             = 1
  records         = [aws_instance.jenkins.public_ip]
  allow_overwrite = true
}

# resource "aws_route53_record" "sonar" {
#   zone_id = var.zone_id
#   name    = "sonarqube.${var.zone_name}"
#   type    = "A"
#   ttl     = 1
#   records = [aws_instance.sonar.public_ip]
#   allow_overwrite = true
# }

resource "aws_route53_record" "jenkins-agent" {
  zone_id         = var.zone_id
  name            = "jenkins-agent.${var.zone_name}"
  type            = "A"
  ttl             = 1
  records         = [aws_instance.jenkins_agent.private_ip]
  allow_overwrite = true
}