resource "aws_efs_file_system" "this" {
  creation_token = "${var.prefix}-${var.environment}"
  encrypted      = true
}

resource "aws_efs_mount_target" "this" {
  count          = length(module.vpc.private_subnets)
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = module.vpc.private_subnets[count.index]
  security_groups = [
    aws_security_group.efs.id
  ]
}

resource "aws_security_group" "efs" {
  name        = "${var.prefix}-efs-${var.environment}"
  description = "EFS security group"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress.id]
  }
}
