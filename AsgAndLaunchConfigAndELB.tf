
provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "all" {
state = "available"
}

# lifecycle attribute is MANDATORY for aws_launch_configuration resource definition
# since lifecycle is defined here, all its dependency shd have this defintion ex:"security group"
resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "terraform-lc-example-"
  image_id = "ami-6f68cf0f"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.sgchellam.name}"]

user_data = <<-EOF
#!/bin/bash
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
cd /var/www/html
echo "<html><h1>hello world - chellam</h1></html>" > index.html
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 2 
  max_size             = 3 


  availability_zones = data.aws_availability_zones.all.names
  load_balancers = ["${aws_elb.bar.name}"]
  health_check_type = "ELB"
}

resource "aws_security_group" "sgchellam" {
  name        = "sgchellam"
  description = "Allow HTTP & SSH inbound traffic"
    lifecycle {
      create_before_destroy = true
    }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = var.port_value
    to_port     = var.port_value
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]


  }



  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

variable port_value {

  description = "enter the port value to get used in all places"
  type = string
  default = 80
}


#OUTPUT ec2_ip {

#VALUE = "${aws_instance.example.public_ip}"
#}


resource "aws_security_group" "elb-sg" {
  name = "terraform-example-elb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elb" "bar" {
  name               = "foobar-terraform-elb"
  availability_zones = data.aws_availability_zones.all.names
  security_groups = ["${aws_security_group.elb-sg.id}"] 


  listener {
    instance_port     = var.port_value 
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3 
    timeout             = 3 
    target              = "HTTP:${var.port_value}/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "foobar-terraform-elb"
  }
}


output "elb_dns_name" {
value = "${aws_elb.bar.dns_name}"
}
