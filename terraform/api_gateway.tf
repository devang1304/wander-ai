# API Gateway REST API
resource "aws_api_gateway_rest_api" "travel_api" {
  name        = "${var.project_name}-api"
  description = "WanderAI Travel Planning API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# CORS Configuration
resource "aws_api_gateway_gateway_response" "cors_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.travel_api.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
}

resource "aws_api_gateway_gateway_response" "cors_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.travel_api.id
  response_type = "DEFAULT_5XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
}

# Research Endpoint
resource "aws_api_gateway_resource" "research" {
  rest_api_id = aws_api_gateway_rest_api.travel_api.id
  parent_id   = aws_api_gateway_rest_api.travel_api.root_resource_id
  path_part   = "research"
}

resource "aws_api_gateway_method" "research_post" {
  rest_api_id   = aws_api_gateway_rest_api.travel_api.id
  resource_id   = aws_api_gateway_resource.research.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "research_lambda" {
  rest_api_id = aws_api_gateway_rest_api.travel_api.id
  resource_id = aws_api_gateway_resource.research.id
  http_method = aws_api_gateway_method.research_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.research_agent.invoke_arn
}

# Planning Endpoint
resource "aws_api_gateway_resource" "plan" {
  rest_api_id = aws_api_gateway_rest_api.travel_api.id
  parent_id   = aws_api_gateway_rest_api.travel_api.root_resource_id
  path_part   = "plan"
}

resource "aws_api_gateway_method" "plan_post" {
  rest_api_id   = aws_api_gateway_rest_api.travel_api.id
  resource_id   = aws_api_gateway_resource.plan.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "plan_lambda" {
  rest_api_id = aws_api_gateway_rest_api.travel_api.id
  resource_id = aws_api_gateway_resource.plan.id
  http_method = aws_api_gateway_method.plan_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.planning_agent.invoke_arn
}

# API Deployment
resource "aws_api_gateway_deployment" "travel_api" {
  depends_on = [
    aws_api_gateway_integration.research_lambda,
    aws_api_gateway_integration.plan_lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.travel_api.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.travel_api.id
  rest_api_id   = aws_api_gateway_rest_api.travel_api.id
  stage_name    = var.environment
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "research_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.research_agent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.travel_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "planning_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.planning_agent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.travel_api.execution_arn}/*/*"
}
