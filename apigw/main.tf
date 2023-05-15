# Configure the AWS Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_api_gateway_rest_api" "apigw" {
    name          = "${var.name}"
    endpoint_configuration {
      types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "apigw_method" {
    rest_api_id   = "${aws_api_gateway_rest_api.apigw.id}"
    resource_id   = "${aws_api_gateway_rest_api.apigw.root_resource_id}"
    http_method   = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_method_response" "apigw_200" {
    rest_api_id   = "${aws_api_gateway_rest_api.apigw.id}"
    resource_id   = "${aws_api_gateway_rest_api.apigw.root_resource_id}"
    http_method   = "${aws_api_gateway_method.apigw_method.http_method}"
    status_code = "200"
    response_models = {
      "application/json" = "Empty"
    }
}

resource "aws_api_gateway_integration" "apigw_integration" {
    rest_api_id   = "${aws_api_gateway_rest_api.apigw.id}"
    resource_id   = "${aws_api_gateway_rest_api.apigw.root_resource_id}"
    http_method   = "${aws_api_gateway_method.apigw_method.http_method}"
    integration_http_method = "ANY"
    type = "HTTP_PROXY"
    uri = "${var.api_uri}"
    passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration_response" "apigw_integration_response" {
    rest_api_id   = "${aws_api_gateway_rest_api.apigw.id}"
    resource_id   = "${aws_api_gateway_rest_api.apigw.root_resource_id}"
    http_method   = "${aws_api_gateway_method.apigw_method.http_method}"
    status_code   = "${aws_api_gateway_method_response.apigw_200.status_code}"
    response_templates = {
      "application/json" = ""
    }
    depends_on = [
      aws_api_gateway_integration.apigw_integration
    ]
}

resource "aws_api_gateway_stage" "apigw_stage" {
    deployment_id = "${aws_api_gateway_deployment.apigw_deploy.id}"
    rest_api_id   = "${aws_api_gateway_rest_api.apigw.id}"
    stage_name    = "login"
}

resource "aws_api_gateway_deployment" "apigw_deploy" {
    rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
    depends_on = [
      aws_api_gateway_method.apigw_method,
      aws_api_gateway_integration.apigw_integration
    ]
}

resource "local_file" "vars" {
  filename = "project_vars.tfvars" 
  file_permission = "0644"
  content = <<-EOT
    aws_region = "${var.aws_region}"
    name = "${var.name}"
    api_uri = "${var.api_uri}"
  EOT
}
