provider "aws" {
region = "us-west-2"
}

resource "aws_instance" "example" {


 ami = "ami-6f68cf0f"
 instance_type ="t2.micro"
 security_groups = ["${aws_security_group.sgchellam.name}"]
 tags =  {
 Name =  "terraform-example"
 }

user_data = <<-EOF
          #!/bin/bash
          yum update -y
          yum install httd -y
          service httpd start
          chkconfig httpd on
          cd /var/www/html
          echo "<html><h1>hello world - chellam</h1></html>" > index.html
          EOF

}



resource "aws_security_group" "sgchellam" {
  name        = "sgchellam"
  description = "Allow HTTP & SSH inbound traffic"

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

#DRY - don't repeat yourself the code in multiple places
#configured port 8080 in variable "port_value" which can be used in multiple places without hardcoding and duplicating value 8080
variable port_value {

  description = "enter the port value to get used in all places"
  type = string
  default = 8080
}

#output variable to print the public ip addr of ec2 -launched
output ec2_ip {
  value = "${aws_instance.example.public_ip}"
}
