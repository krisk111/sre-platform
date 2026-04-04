terraform {
  backend "s3" {
    bucket         = "sre-platform-tfstate-281459851067"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sre-platform-tfstate-lock"
    encrypt        = true
  }
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}
provider "aws" { region = "us-east-1" }
 
module "vpc" {
  source  = "../../modules/vpc"
  project = "sre-platform"
  env     = "dev"
  vpc_cidr= "10.0.0.0/16"
  azs     = ["us-east-1a","us-east-1b"]
}
 
module "eks" {
  source             = "../../modules/eks"
  cluster_name       = "sre-platform-dev"
  private_subnet_ids = module.vpc.private_subnet_ids
}
 
module "ecr" {
  source        = "../../modules/ecr"
  project       = "sre-platform"
  service_names = ["api-service","worker-service","frontend-service"]
}
