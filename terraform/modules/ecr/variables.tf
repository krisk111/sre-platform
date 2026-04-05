variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "service_names" {
  description = "List of service names for which ECR repos will be created"
  type        = list(string)
}