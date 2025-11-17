terraform {
  backend "s3" {
    bucket         = "med-app-remotestate-prod"
    key            = "med-app/prod/platform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "med-app-locking-prod"
    encrypt        = true
  }
}

