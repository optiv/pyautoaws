output "deployment_invoke_url" {
  description = "Deployment invoke URL"
  value       = aws_api_gateway_stage.apigw_stage.invoke_url
}
