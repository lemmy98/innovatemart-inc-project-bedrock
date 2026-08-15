# Optional — used by CI. Local first apply can stay without a backend, then:
#   terraform init -migrate-state -backend-config=backend.hcl
#
# backend.hcl is gitignored; CI writes it from TF_STATE_BUCKET.
terraform {
  backend "s3" {}
}
