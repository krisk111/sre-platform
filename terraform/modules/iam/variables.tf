variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "role_name" {
  description = "IAM role name suffix"
  type        = string
}

variable "assume_role_principal" {
  description = "Principal allowed to assume this role"
  type        = map(string)
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default     = []
}