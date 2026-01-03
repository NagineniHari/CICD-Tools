locals{
    ami_id = data.aws_ami.iqvia.id
        common_tags = {
        Project = var.project_name
        Environment = var.environment
        Terraform = "true"
    }
}