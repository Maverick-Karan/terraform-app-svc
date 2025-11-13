terraform {
  backend "s3" {
    bucket         = "med-app-remotestate-prod"
    key            = "med-app/prod.tfstate"
    region         = "us-east-1"
    dynamodb_table = "med-app-locking"
    encrypt        = true
  }
}

