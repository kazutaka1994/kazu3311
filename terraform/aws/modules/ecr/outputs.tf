output "ecr_repository_arn" {
  value = aws_ecr_repository.default.arn
}

output "ecr_repository_id" {
  value = aws_ecr_repository.default.registry_id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.default.repository_url
}
