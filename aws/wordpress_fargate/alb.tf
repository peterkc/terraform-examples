module "acm_alb" {
  source      = "terraform-aws-modules/acm/aws"
  version     = "~> v3.0"
  domain_name = var.public_alb_domain
  zone_id     = data.aws_route53_zone.this.zone_id
}

resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb-${var.environment}"
  description = "Allow HTTPS inbound traffc"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
}


module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 6.0"
  name               = "${var.prefix}-${var.environment}"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]

  https_listeners = [
    {
      "certificate_arn" = module.acm_alb.acm_certificate_arn
      "port"            = 443
      "ssl_policy"      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
    },
  ]

  target_groups = [
    {
      name             = "${var.prefix}-default-${var.environment}"
      backend_protocol = "HTTP"
      backend_port     = 80
    }
  ]
}
