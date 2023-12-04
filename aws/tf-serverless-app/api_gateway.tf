resource "aws_api_gateway_rest_api" "api" {

  name = "api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "petcuddletron"
}

resource "aws_api_gateway_method" "post_api" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.post_api.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = aws_lambda_function.api_lambda.invoke_arn
}

module "api-gateway-enable-cors" {

source  = "squidfunk/api-gateway-enable-cors/aws"
version = "0.3.3"
api_id          = aws_api_gateway_rest_api.api.id

api_resource_id = aws_api_gateway_resource.api.id

}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on       = [aws_api_gateway_integration.lambda_integration]

  rest_api_id      = aws_api_gateway_rest_api.api.id
  stage_name       = "dev"
  stage_description = "Development Stage"
}

resource "aws_iam_role" "apigateway_logs_role" {

  name = "APIGatewayRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = "CloudWatchLogsPolicy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }]
    })
  }

  inline_policy {
    name = "APIGatewayInvokeLambdaPolicy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect    = "Allow",
        Action    = "lambda:InvokeFunction",
        Resource  = aws_lambda_function.api_lambda.arn
      }]
    })
  }
}

# resource "aws_api_gateway_account" "api_gateway_logs" {
#   cloudwatch_role_arn = aws_iam_role.apigateway_logs_role.arn
#   depends_on = [ aws_iam_role.apigateway_logs_role ]
# }


# resource "aws_api_gateway_stage" "stage" {
#   depends_on = [aws_api_gateway_deployment.deployment]

#   rest_api_id = aws_api_gateway_rest_api.api.id
#   stage_name  = aws_api_gateway_deployment.deployment.stage_name

#   deployment_id = aws_api_gateway_deployment.deployment.id
# }









# resource "aws_api_gateway_method" "options_method" {
#     rest_api_id   = aws_api_gateway_rest_api.api.id
#     resource_id   = aws_api_gateway_resource.api.id
#     http_method   = "OPTIONS"
#     authorization = "NONE"
# }

# resource "aws_api_gateway_method_response" "options_200" {
#     rest_api_id   = aws_api_gateway_rest_api.api.id
#     resource_id   = aws_api_gateway_resource.api.id
#     http_method   = aws_api_gateway_method.options_method.http_method
#     status_code   = "200"

#     response_models = {
#         "application/json" = "Empty"
#     }

#     response_parameters = {
#         "method.response.header.Access-Control-Allow-Headers" = true,
#         "method.response.header.Access-Control-Allow-Methods" = true,
#         "method.response.header.Access-Control-Allow-Origin" = true
#     }

#     depends_on = [aws_api_gateway_method.options_method]
# }

# resource "aws_api_gateway_integration" "options_integration" {

#     rest_api_id   = aws_api_gateway_rest_api.api.id
#     resource_id   = aws_api_gateway_resource.api.id
#     http_method   = aws_api_gateway_method.options_method.http_method

#     type          = "MOCK"
#     depends_on = [aws_api_gateway_method.options_method]
# }

# resource "aws_api_gateway_integration_response" "options_integration_response" {

#     rest_api_id   = aws_api_gateway_rest_api.api.id
#     resource_id   = aws_api_gateway_resource.api.id
#     http_method   = aws_api_gateway_method.options_method.http_method
#     status_code   = aws_api_gateway_method_response.options_200.status_code

#     response_parameters = {
#         "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
#         "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
#         "method.response.header.Access-Control-Allow-Origin" = "'*'"
#     }

#     depends_on = [aws_api_gateway_method_response.options_200]
# }

