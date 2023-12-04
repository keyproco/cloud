data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./src/notify.py"
  output_path = "./src/notify.zip"
}

resource "aws_lambda_function" "notify" {
  filename      = "./src/notify.zip"
  function_name = "notify"
  role          = aws_iam_role.lambda_notification_role.arn
  handler       = "notify.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime          = "python3.8" 

  environment {
    variables = {
      role = "notify"
    }
  }

}

resource "aws_iam_role" "lambda_notification_role" {
  name = "lambda_notify_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole",
    }],
  })

  inline_policy {
    name = "allow_all_lambda_ses_sns_states_policy"
    policy = jsonencode({
      Statement = [{
        Effect    = "Allow",
        Action    = [
          "ses:*",
          "sns:*",
          "states:*",
        ],
        Resource = "*"
      }]
    })
  }
}

resource "aws_iam_role_policy_attachment" "basic_lambda_permissions" {
  role       = aws_iam_role.lambda_notification_role.name 
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 
}


resource "aws_ses_email_identity" "sender" {
  email = var.sender_email
}
