# Configuración del proveedor de AWS
provider "aws" {
  region = "us-east-1"  # Cambia a tu región preferida
  profile = "default"
}

# Configuración del backend para almacenar el estado en S3
terraform {
  backend "s3" {
    bucket = "bucket-terraform-state"  # Reemplaza con el nombre de tu bucket S3
    key    = "terraform/ec2-instances/terraform.tfstate"
    region = "us-east-1"  # Región donde se encuentra tu bucket
     profile = "default"
    # Opcional: Si deseas usar DynamoDB para bloqueo de estado
    # dynamodb_table = "terraform-lock"
  }
}

# Variables para recursos existentes
variable "ami_ids" {
  description = "IDs de las AMIs para cada instancia EC2"
  type        = list(string)
}

variable "instance_types" {
  description = "Tipos de instancia EC2 para cada instancia"
  type        = list(string)
  default     = ["t2.micro", "t2.micro"]
}

variable "key_pair_names" {
  description = "Nombres de los key pairs para cada instancia"
  type        = list(string)
}

variable "subnet_ids" {
  description = "IDs de las subnets donde se desplegarán las instancias"
  type        = list(string)
}

variable "security_group_ids_instance1" {
  description = "IDs de los grupos de seguridad para la primera instancia"
  type        = list(string)
}

variable "security_group_ids_instance2" {
  description = "IDs de los grupos de seguridad para la segunda instancia"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID de la VPC donde se crearán las instancias"
  type        = string
  default     = "vpc-0f55183a175406bcc"  # Actualiza con tu VPC ID real
}

variable "instance_names" {
  description = "Nombres para las instancias EC2"
  type        = list(string)
  default     = ["instance-1", "instance-2"]
}

# Recursos para crear las instancias EC2 con diferentes AMIs y key pairs
resource "aws_instance" "ec2_instance_1" {
  ami                    = var.ami_ids[0]
  instance_type          = var.instance_types[0]
  key_name               = var.key_pair_names[0]
  iam_instance_profile = "ssm-role"
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = var.security_group_ids_instance1
  user_data = <<EOF
          #!/bin/bash
          cd /tmp
          sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
          sudo systemctl enable amazon-ssm-agent
          sudo systemctl start amazon-ssm-agent
        EOF

  tags = {
    Name = var.instance_names[0]
    Environment = "Development"
    ManagedBy = "Terraform"
    BackupSchedule = "True"
    BackupPeriod = "Daily"
    BackupEnviroment = "Dev"
    BackupRetention = "3Days"
    EC2-Start = "MON-FRI-0600"
    EC2-Stop = "MON-FRI-2000"
    BackupTime = "0300"
  }
}

resource "aws_instance" "ec2_instance_2" {
  ami                    = var.ami_ids[1]
  instance_type          = var.instance_types[1]
  key_name               = var.key_pair_names[1]
  iam_instance_profile = "ssm-role"
  subnet_id              = var.subnet_ids[length(var.subnet_ids) > 1 ? 1 : 0]
  vpc_security_group_ids = var.security_group_ids_instance2
  user_data = <<EOF
          #!/bin/bash
          cd /tmp
          sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
          sudo systemctl enable amazon-ssm-agent
          sudo systemctl start amazon-ssm-agent
        EOF

  tags = {
    Name = var.instance_names[1]
    Environment = "Development"
    ManagedBy = "Terraform"
    BackupSchedule = "True"
    BackupPeriod = "Daily"
    BackupEnviroment = "Dev"
    BackupRetention = "3Days"
    EC2-Start = "MON-FRI-0600"
    EC2-Stop = "MON-FRI-2000"
    BackupTime = "0300"
  }
}

# Outputs para obtener información de las instancias creadas
output "instance_1_id" {
  value = aws_instance.ec2_instance_1.id
}

output "instance_1_private_ip" {
  value = aws_instance.ec2_instance_1.private_ip
}

output "instance_1_public_ip" {
  value = aws_instance.ec2_instance_1.public_ip
}

output "instance_1_key_pair" {
  value = aws_instance.ec2_instance_1.key_name
}

output "instance_2_id" {
  value = aws_instance.ec2_instance_2.id
}

output "instance_2_private_ip" {
  value = aws_instance.ec2_instance_2.private_ip
}

output "instance_2_public_ip" {
  value = aws_instance.ec2_instance_2.public_ip
}

output "instance_2_key_pair" {
  value = aws_instance.ec2_instance_2.key_name
}

output "instance_1_security_groups" {
  value = aws_instance.ec2_instance_1.vpc_security_group_ids
}

output "instance_2_security_groups" {
  value = aws_instance.ec2_instance_2.vpc_security_group_ids
}