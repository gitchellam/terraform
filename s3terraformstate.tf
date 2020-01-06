provider "aws" {
region = "us-west-2"
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-2425048"
  force_destroy = true

  versioning {
    enabled = true 
  }

# lifecycle {
#   prevent_destroy = true 
# }

}


terraform {
  backend "s3" {
    bucket  = "terraform-up-and-running-state-2425048"
    region  = "us-west-2"
    key     = "terraform.tfstate"
    encrypt = true    
  }
}

