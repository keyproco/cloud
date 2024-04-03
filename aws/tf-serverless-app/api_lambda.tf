data "archive_file" "api_lambda" {
  type        = "zip"
  source_file = "./src/api_lambda.py"
  output_path = "./src/api_lambda.zip"
}

resource "aws_lambda_function" "api_lambda" {
  filename      = "./src/api_lambda.zip"
  function_name = "api_lambda"
  role          = aws_iam_role.lambda_notification_role.arn
  handler       = "api_lambda.lambda_handler"

  source_code_hash = data.archive_file.api_lambda.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      SM_ARN = aws_sfn_state_machine.sfn_state_machine.arn
    }
  }
}


resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = aws_api_gateway_rest_api.api.arn
}
