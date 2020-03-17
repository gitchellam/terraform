

provider "aws" {
region = "us-west-2"
}

resource "aws_instance" "example" {
	ami = "ami-0ce21b51cb31a48b8"
	instance_type = "t2.micro"
tags ={
    Name = "terraform-example"
  }
}
