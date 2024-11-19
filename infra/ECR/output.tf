output "repository_urls" {
  value = aws_ecr_repository.ecr_repos[*].repository_url
}

output "repository_arns" {
  value = aws_ecr_repository.ecr_repos[*].arn
}
