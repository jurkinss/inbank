terraform {
  backend "s3" {
    bucket         = "inbank-state"
    key            = "demo.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "a-ddb-inbank"
    profile        = "inbank"
  }
}
