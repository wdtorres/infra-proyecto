terraform {
  backend "s3" {
    bucket = "buck-david-estado-tf01"
    key    = "infra.tfstate"
    region = "us-east-1"
  }
}