resource "null_resource" "install_dependencies" {
  triggers = {
    requirements = filesha256("${path.module}/../backend/src/requirements.txt")
    source_code  = sha256(join("", [for f in fileset("${path.module}/../backend/src", "**/*.py") : filesha256("${path.module}/../backend/src/${f}")]))
  }

  provisioner "local-exec" {
    command = <<EOT
      rm -rf ${path.module}/../backend/build
      mkdir -p ${path.module}/../backend/build
      pip install -r ${path.module}/../backend/src/requirements.txt -t ${path.module}/../backend/build
      cp -r ${path.module}/../backend/src/* ${path.module}/../backend/build/
    EOT
  }
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/../backend/build"
  output_path = "${path.module}/lambda_function.zip"
  depends_on  = [null_resource.install_dependencies]
}

# DynamoDB Table for Travel Itineraries
resource "aws_dynamodb_table" "travel_table" {
  name         = "${var.project_name}-travel-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-travel-table"
  }
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.travel_table.arn
      }
    ]
  })
}

# Research Agent Lambda Function
resource "aws_lambda_function" "research_agent" {
  filename         = data.archive_file.lambda_package.output_path
  function_name    = "${var.project_name}-research-agent"
  role             = aws_iam_role.lambda_role.arn
  handler          = "agents.research_agent.lambda_handler"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  runtime          = "python3.9"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory
  architectures    = ["arm64"]

  environment {
    variables = {
      OPENAI_API_KEY = var.openai_api_key
      TABLE_NAME     = aws_dynamodb_table.travel_table.name
    }
  }
}

# Planning Agent Lambda Function
resource "aws_lambda_function" "planning_agent" {
  filename         = data.archive_file.lambda_package.output_path
  function_name    = "${var.project_name}-planning-agent"
  role             = aws_iam_role.lambda_role.arn
  handler          = "agents.planning_agent.lambda_handler"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  runtime          = "python3.9"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory
  architectures    = ["arm64"]

  environment {
    variables = {
      OPENAI_API_KEY = var.openai_api_key
      TABLE_NAME     = aws_dynamodb_table.travel_table.name
    }
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "research_agent_logs" {
  name              = "/aws/lambda/${aws_lambda_function.research_agent.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "planning_agent_logs" {
  name              = "/aws/lambda/${aws_lambda_function.planning_agent.function_name}"
  retention_in_days = 7
}
