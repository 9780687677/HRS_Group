provider "aws" {
  region = "us-east-1"  # Change the region if needed
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
  capacity_providers = ["FARGATE"]
}

# Create ECS Task Definition
resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.my_task_execution_role.arn
  container_definitions    = <<EOF
  [
    {
      "name": "my-container",
      "image": "your-docker-image-url",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ]
    }
  ]
  EOF
}

# Create ECS Service
resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = aws_subnet.my_subnet.*.id
    assign_public_ip = true
    security_groups  = [aws_security_group.my_security_group.id]
  }
}

# Create DNS Zone
resource "aws_route53_zone" "my_dns_zone" {
  name = "example.com"
}

# Create DNS Record
resource "aws_route53_record" "my_dns_record" {
  zone_id = aws_route53_zone.my_dns_zone.zone_id
  name    = "my-service.example.com"
  type    = "A"
  ttl     = "300"
  records = [aws_ecs_service.my_service.load_balancer.first_in_first_out_dns_name]
}

# Create ECS Task Execution Role
resource "aws_iam_role" "my_task_execution_role" {
  name = "my-task-execution-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Create Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Create Security Group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  # Define security group rules as needed
}
