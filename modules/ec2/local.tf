locals {
  ec2_userdata_script = templatefile("${path.module}/scripts/user_data.sh.tpl", {
    datadog_api_key = var.datadog_api_key
  })
}