terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0d2cf42446f3c926b"
  instance_type = "t2.micro"
  key_name      = "chave-windows"
  tags = {
    Name = "vm-windows-01"
  }

  # Cria regras para as portas HTTP 5985 e NTLM 1433 no Firewall do Windows 2019
  user_data = <<-EOF
    <powershell>
    New-NetFirewallRule -DisplayName "Allow WinRM" -Name "Allow WinRM" -Profile Any -LocalPort 5985 -Protocol TCP
    New-NetFirewallRule -DisplayName "Allow WinRM" -Name "Allow WinRM" -Profile Any -LocalPort 1433 -Protocol TCP
    </powershell>
EOF
}

resource "aws_security_group" "acesso_geral" {
  name        = "acesso_geral"
  description = "Grupo de Seguranca de VMs Web"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "acesso_geral"
  }
}

output "public_ipvm" {
  value = aws_instance.app_server.public_ip
}

