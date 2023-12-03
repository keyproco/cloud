
resource "aws_iam_role" "states_notification" {
  name = "states_notify_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
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
          "sns:*",
          "lambda:invokeFunction",
          "logs:*"
        ],
        Resource = "*"
      }]
    })
  }
}

resource "aws_cloudwatch_log_group" "notification" {
  name = "notification"

  tags = {
    Environment = "dev"
  }
}


resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "notification-timer"
  role_arn = "${aws_iam_role.states_notification.arn}"

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.notification.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  definition = <<EOF
{
  "Comment": "Notification - using Lambda for email.",
  "StartAt": "Timer",
  "States": {
    "Timer": {
      "Type": "Wait",
      "SecondsPath": "$.waitSeconds",
      "Next": "Email"
    },
    "Email": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${aws_lambda_function.notify.arn}",
        "Payload": {
          "Input.$": "$"
        }
      },
      "Next": "NextState"
    },
    "NextState": {
      "Type": "Pass",
      "End": true
    }
  }
}
EOF
}
