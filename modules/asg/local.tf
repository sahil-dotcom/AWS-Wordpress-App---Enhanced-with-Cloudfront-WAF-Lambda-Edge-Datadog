locals {
  userdata_script = templatefile("${path.module}/scripts/asg_user_data.sh.tpl", {
    datadog_api_key = var.datadog_api_key
  })
}
