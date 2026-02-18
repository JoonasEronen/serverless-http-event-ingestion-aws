resource "aws_lambda_function" "ingestion" {
  function_name = "${local.name_prefix}-event-ingestion"
  role          = aws_iam_role.lambda_exec.arn

  runtime = "python3.12"
  handler = "lambda_handler.lambda_handler"

  filename         = "${path.root}/build/lambda.zip"
  source_code_hash = filebase64sha256("${path.root}/build/lambda.zip")

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.events.name
    }
  }

}

output "lambda_function_name" {
  value = aws_lambda_function.ingestion.function_name
}
