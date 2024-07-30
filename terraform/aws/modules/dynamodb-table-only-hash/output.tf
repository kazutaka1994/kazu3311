output "dynamodb_table_arn" {
    value = aws_dynamodb_table.only_hash.arn
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.only_hash.id
}