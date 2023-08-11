provider "aws" {
  region = "eu-west-1"
}

terraform {
  # Fill this block with your actual backend configuration
  backend "s3" {
    region = "eu-west-1"
    bucket = "xxxxxx"
    key    = "xxxxxx"
  }
}
