terraform {
  backend "s3" {
    bucket = "nr-terraform-state-bucket"
    key    = "terraform/projects/labs/vsppoc"
    region = "us-east-1"
  }
}
