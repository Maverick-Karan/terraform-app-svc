terraform {
  backend "s3" {
    bucket         = "med-app-remotestate"
    key            = "med-app/stage/platform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "med-app-locking"
    encrypt        = true
  }
}

