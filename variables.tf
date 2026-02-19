variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "project" {
  type    = string
  default = "hashitalks-tfaction-demo"
}

variable "email" {
  type    = string
  default = ""
}

# Change this to trigger the automated workflow (backup + notify + log)
variable "release_version" {
  type    = string
  default = "v1"
}

# Turn on/off the automatic lifecycle-triggered workflow
variable "enable_release_workflow" {
  type    = bool
  default = true
}

# Message for manual publish
variable "message" {
  type    = string
  default = "Hello from Terraform Actions"
}

# Retention for CloudWatch logs (days)
variable "log_retention_days" {
  type    = number
  default = 7
}
