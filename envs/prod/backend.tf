terraform {
  backend "s3" {
    bucket         = "company-tfstate-prod"
    key            = "app-services/ecr.tfstate"
    region         = "us-east-1"
    dynamodb_table = "company-tf-locks-prod"
    encrypt        = true
  }
}

