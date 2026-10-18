# Terraform foundation

`modules/` contains reusable AWS foundation modules. `environments/` composes
them for a named environment. Each environment is a separate Terraform root and
therefore a separate state boundary once a backend is chosen.

Use `terraform.tfvars.example` as the starting point for local values. Do not
commit credentials, state, or environment-specific `.tfvars` files.
