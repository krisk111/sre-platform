output "repository_urls" {
  description = "Map of service name to repository URL"
  value = {
    for svc, repo in aws_ecr_repository.repos : svc => repo.repository_url
  }
}

output "repository_names" {
  description = "Map of service name to repository name"
  value = {
    for svc, repo in aws_ecr_repository.repos : svc => repo.name
  }
}