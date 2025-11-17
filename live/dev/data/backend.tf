terraform {
  backend "s3" {
    bucket         = "med-app-remotestate"
    key            = "med-app/dev/data.tfstate"
    region         = "us-east-1"
    dynamodb_table = "med-app-locking"
    encrypt        = true
  }
}

