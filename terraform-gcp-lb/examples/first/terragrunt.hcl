generate "common_vars" {
    
    path = "common_vars.yaml"
    if_exists = "overwrite_terragrunt"

    contents = <<EOF
---
var1: value_of_var1
bucket: ssita
prefix: terraform/terraform_terragrunt
credentials: /home/wlados/.gcp/terraform.json
project: helical-history-342218
region: us-central1
zone: us-central1-a
...
EOF
}

locals {
#    common_vars = yamldecode(file("common_vars.yaml"))

    bucket = "ssita"
    prefix  = "terraform/terraform_terragrunt"
    credentials = "/home/wlados/.gcp/terraform.json"

    project = "helical-history-342218"
    region  = "us-central1"
    zone    = "us-central1-a"

    root_dir = get_parent_terragrunt_dir()
}


remote_state {
    
    backend = "gcs"
    
    generate = {
        path      = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }

    config = {
        credentials = local.credentials
        bucket = local.bucket
        prefix  = local.prefix
    }
}

generate "provider" {

    path = "providers.tf"
    if_exists = "overwrite_terragrunt"

    contents = <<EOF

provider "google" { 
    credentials = "${local.credentials}"
    project = "${local.project}"
    region  = "${local.region}"
    zone    = "${local.zone}"
}

EOF
}
