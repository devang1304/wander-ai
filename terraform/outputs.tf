output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "research_function_name" {
  description = "Research Lambda function name"
  value       = aws_lambda_function.research_agent.function_name
}

output "planning_function_name" {
  description = "Planning Lambda function name"
  value       = aws_lambda_function.planning_agent.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.travel_table.name
}

output "frontend_bucket_name" {
  description = "S3 bucket for frontend hosting"
  value       = aws_s3_bucket.frontend_bucket.id
}

output "frontend_url" {
  description = "CloudFront URL for frontend"
  value       = "https://${aws_cloudfront_distribution.frontend_distribution.domain_name}"
}
