include {
    path = find_in_parent_folders()
}

locals {
    common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

terraform {
    source = "../../..//modules/simple"

    error_hook "error_hook_1" {
        commands  = ["apply", "plan"]
        execute   = ["echo", "... shit happens ..."]
        on_errors = [
            ".*",
        ]
    }
}
