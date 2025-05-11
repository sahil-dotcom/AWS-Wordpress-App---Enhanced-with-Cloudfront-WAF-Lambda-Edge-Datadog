
module "network" {
  source = "./modules/vpc"

  default-route = var.default-route
  projectname   = var.projectname
  vpc_cidr      = var.vpc_cidr
  environment   = var.environment
}

module "eic" {
  source = "./modules/eic"

  projectname     = var.projectname
  environment     = var.environment
  subnet_id       = module.network.private_subnet_ids[0]
  security_groups = [module.security.eic_sg_id]
}


module "security" {
  source = "./modules/sg"

  vpc_id        = module.network.vpc_id
  vpc_cidr      = var.vpc_cidr
  default-route = var.default-route
  projectname   = var.projectname
  environment   = var.environment
}

module "ec2" {
  source = "./modules/ec2"

  projectname          = var.projectname
  depends_on           = [module.rds]
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  aws_region           = var.aws_region
  subnet_id            = module.network.private_subnet_ids[1]
  security_group_ids   = [module.security.ec2_sg_id]
  target_group_arn     = module.alb.target_group_arn
  ec2_instance_type    = var.ec2_instance_type
  iam_instance_profile = module.iam.iam_instance_profile_name
  rds_id               = module.rds.rds_id
  efs_id               = module.efs.efs_id
  rds_secret_arn       = module.rds.rds_secret_arn
  datadog_api_key      = var.datadog_api_key
}


module "efs" {
  source = "./modules/efs"

  projectname     = var.projectname
  environment     = var.environment
  subnet_ids      = module.network.private_subnet_ids
  security_groups = [module.security.efs_sg_id]
}


module "rds" {
  source = "./modules/rds"

  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version
  db_instance_class = var.db_instance_class
  db_storage_size   = var.db_storage_size
  db_storage_type   = var.db_storage_type
  projectname       = var.projectname
  environment       = var.environment
  db_name           = var.db_name
  db_username       = var.db_username
  subnet_ids        = module.network.private_subnet_ids
  security_groups   = [module.security.rds_sg_id]
}


module "alb" {
  source = "./modules/alb"

  load_balancer_type  = var.load_balancer_type
  projectname         = var.projectname
  environment         = var.environment
  vpc_id              = module.network.vpc_id
  subnet_ids          = module.network.public_subnet_ids
  security_groups     = [module.security.alb_sg_id]
  acm_certificate_arn = module.acm.cert_arn
  log_bucket          = module.logging.alb_logs_bucket
}

module "asg" {
  source = "./modules/asg"

  depends_on        = [module.ec2]
  alb_instance_type = var.alb_instance_type
  instance_profile  = module.iam.iam_instance_profile_name
  desired_capacity  = var.desired_capacity
  min_size          = var.min_size
  max_size          = var.max_size
  projectname       = var.projectname
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.private_subnet_ids
  security_groups   = [module.security.ec2_sg_id]
  target_group_arn  = module.alb.target_group_arn
  datadog_api_key   = var.datadog_api_key
}

module "acm" {
  source                              = "./modules/acm"
  domain_name                         = var.domain_name
  environment                         = var.environment
  hosted_zone_id                      = module.dns.zone_id
  cloudfront_distribution_domain_name = module.cloudfront.domain_name
  cloudfront_hosted_zone_id           = module.cloudfront.hosted_zone_id
  depends_on                          = [module.dns]
}

module "dns" {
  source      = "./modules/dns"
  domain_name = var.domain_name
}

module "cloudfront" {
  source                 = "./modules/cdn"
  projectname            = var.projectname
  environment            = var.environment
  domain_name            = var.domain_name
  alb_dns_name           = module.alb.alb_dns_name
  acm_certificate_arn    = module.acm.cert_arn
  waf_acl_arn            = module.waf.cloudfront_waf_arn
  lambda_arn             = module.lambda_edge.lambda_arn
  cloudfront_bucket_name = module.logging.cloudfront_logs_buckets
}

module "iam" {
  source                      = "./modules/iam"
  projectname                 = var.projectname
  environment                 = var.environment
  lambda_role_name            = var.lambda_role_name
  db_secret_arn               = module.rds.rds_secret_arn
  cloudfront_distribution_id  = module.cloudfront.cloudfront_distribution_id
  cloudfront_logs_bucket_name = module.logging.cloudfront_logs_bucket
  alb_logs_bucket_name        = module.logging.alb_logs_bucket
  datadog_role_name           = var.datadog_role_name
  aws_account_id              = var.aws_account_id
  datadog_account_id          = var.datadog_account_id
  external_id                 = module.datadog_dashboard.external_id
  alb_logs_bucket_arn         = module.logging.alb_logs_bucket_arn
  cloudfront_logs_bucket_arn  = module.logging.cloudfront_logs_bucket_arn
  lambda_edge_fuction         = var.lambda_name
  datadog_function            = var.datadog_function
}

module "lambda_edge" {
  source                      = "./modules/lam_e"
  lambda_name                 = var.lambda_name
  lambda_role_arn             = module.iam.lambda_iam_role_arn
  environment                 = var.environment
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn
  lambda_role_name            = var.lambda_role_name
  cloudfront_logs_bucket_arn  = module.logging.cloudfront_logs_bucket_arn
  alb_logs_bucket_arn         = module.logging.alb_logs_bucket_arn
  datadog_api_key             = var.datadog_api_key
}

module "waf" {
  source = "./modules/waf"

  projectname = var.projectname
  environment = var.environment
  waf_name    = var.waf_name
  aws_region  = var.aws_region
}

module "logging" {
  source = "./modules/log"

  environment                  = var.environment
  projectname                  = var.projectname
  cloudfront_logs_policy_json  = module.iam.cloudfront_logs_policy_json
  alb_logs_policy_json         = module.iam.alb_logs_policy_json
  cent_logs_policy_json        = module.iam.cent_logs_policy_json
  datadog_api_key              = var.datadog_api_key
  vpc_id                       = module.network.vpc_id
  iam_role_arn                 = module.iam.flow_log_role_arn
  aws_account_id               = var.aws_account_id
  datadog_forwarder_lambda_arn = module.lambda_edge.datadatadog_forwarder_lambda_arn
}

module "datadog_dashboard" {
  source            = "./modules/datadog"
  dashboard_title   = var.dashboard_title
  datadog_api_key   = var.datadog_api_key
  datadog_app_key   = var.datadog_app_key
  datadog_role_name = module.iam.datadog_integration_role_name
  datadog_role_arn  = module.iam.datadog_integration_role_arn
}
