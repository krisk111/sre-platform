resource "aws_ecr_repository" "repos" {
  for_each = toset(var.service_names)

  name                 = "${var.project}/${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project   = var.project
    ManagedBy = "terraform"
    Service   = each.value
  }
}