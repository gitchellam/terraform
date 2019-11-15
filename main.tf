provider "aws" {
region = "us-west-2"
}

resource "aws_instance" "example" {
 ami = "ami-6f68cf0f"
 instance_type ="t2.micro"
 tags =  {
 Name =  "terraform-example"
 }


}
