remote_state {
    backend  = "s3"
    generate = {
        path      = "backend.tf"
        if_exists = "overwrite_terragrunt"
        contents = <<EOF
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
    EOF
    }
    config = {
        bucket = "tr-bucket-kr-v"

        key = "${path_relative_to_include()}/terraform.tfstate"
        region         = "us-east-1"
        encrypt        = true
        dynamodb_table = "terraform-state-lock-dynamo"
    }

}

generate "provider" {
        path = "provider.tf"
        if_exists = "overwrite_terragrunt"
        contents = <<EOF
provider "aws" {
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
    profile                 = "default"
}
    EOF
    }