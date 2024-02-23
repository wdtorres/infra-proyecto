# Create a VPC
resource "aws_vpc" "vpc-dtu-proyecto" {
  cidr_block = "10.0.0.0/27"
  tags = {
    Name = "vpc-infra-proyecto"
  }
}
resource "aws_subnet" "sub-ext1-proyecto" {
  vpc_id     = aws_vpc.vpc-dtu-proyecto.id
  cidr_block = "10.0.0.0/28"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Internet-proyecto"
  }
}
resource "aws_subnet" "sub-ext2-proyecto" {
  vpc_id     = aws_vpc.vpc-dtu-proyecto.id
  cidr_block = "10.0.0.16/28"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Internet2-proyecto"
  }
}
resource "aws_internet_gateway" "gtwyintr" {
  vpc_id = aws_vpc.vpc-dtu-proyecto.id

  tags = {
    Name = "Gateway Principal"
  }
}
resource "aws_route_table" "tbl-externa" {
  vpc_id = aws_vpc.vpc-dtu-proyecto.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gtwyintr.id
  }

  tags = {
    Name = "Tabla rutas Externa"
  }
}
resource "aws_route_table_association" "asocia-tbl-extrna1" {
  subnet_id      = aws_subnet.sub-ext1-proyecto.id
  route_table_id = aws_route_table.tbl-externa.id
}
resource "aws_route_table_association" "asocia-tbl-extrna2" {
  subnet_id      = aws_subnet.sub-ext2-proyecto.id
  route_table_id = aws_route_table.tbl-externa.id
}

#Aqui va el balanceador de carga:
resource "aws_lb" "balance-proy" {
  name               = "Balanceador-carga-pry"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security-grp-pry.id]
  subnets            = [aws_subnet.sub-ext2-proyecto.id, aws_subnet.sub-ext1-proyecto.id]
}

# aqui va el target group
resource "aws_lb_target_group" "targer-frp-pry" {
  name        = "Target-gropup-pry"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-dtu-proyecto.id
  target_type = "ip"
}

# Aqui va el listener del balanceador
resource "aws_lb_listener" "listener-pry" {
  load_balancer_arn = aws_lb.balance-proy.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targer-frp-pry.arn
  }
}

# Crear una regla de enrutamiento para el balanceador de carga
#resource "aws_lb_target_group_attachment" "tarjetgrp-pry" {
#  target_group_arn = aws_lb_target_group.targer-frp-pry.arn
#  target_id        = contenedor-pry.id
#  port             = 80
#}

resource "aws_security_group" "security-grp-pry" {
  name        = "security-grp-pry"
  description = "grupo se seguridad del proyecto regla puerto 80"
  vpc_id      = aws_vpc.vpc-dtu-proyecto.id

  // Reglas de entrada
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite el tráfico desde cualquier IP en el puerto 80
  }
}
