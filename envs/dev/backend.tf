terraform {
  backend "s3" {
    bucket         = "company-tfstate-dev"
    key            = "app-services/ecr.tfstate"
    region         = "us-east-1"
    dynamodb_table = "company-tf-locks-dev"
    encrypt        = true
  }
}

