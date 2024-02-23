resource "aws_ecs_cluster" "cluster-pry" {
  name = "cluster-proyecto"
}

#Tareilla:
resource "aws_ecs_task_definition" "tarea-pry" {
  family                   = "tarea-pry"
  cpu                      = "256" # Cantidad de CPU en milicore
  memory                   = "512" # Cantidad de memoria en MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "contenedor-pry"
      image     = "730335645538.dkr.ecr.us-east-1.amazonaws.com/contenedor-pry:latest"
      cpu       = 256 # Cantidad de CPU en milicore
      memory    = 512 # Cantidad de memoria en MiB
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "servicio-pry" {
  name            = "servicio-pry"
  cluster         = aws_ecs_cluster.cluster-pry.id
  task_definition = aws_ecs_task_definition.tarea-pry.arn
  desired_count   = 1

  # Configuración del servicio para Fargate
  launch_type = "FARGATE"

  # Configuración de red
  network_configuration {
    subnets          = [aws_subnet.sub-ext2-proyecto.id, aws_subnet.sub-ext1-proyecto.id]  
    assign_public_ip = true
    security_groups  = [aws_security_group.security-grp-pry.id]  # Reemplaza con tu grupo de seguridad
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.targer-frp-pry.arn
    container_name   = "contenedor-pry"
    container_port   = 80
  }
}