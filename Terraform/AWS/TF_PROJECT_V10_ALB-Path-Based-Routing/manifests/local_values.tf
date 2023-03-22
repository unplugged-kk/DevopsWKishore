#Define Local Values in Terraform

locals {
  owners      = var.business_divsion
  environment = var.environment
  name        = "${var.business_divsion}-${var.environment}" #Anything we can use 
  #   name = "${local.owners}-${local-environment}"

  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}

locals {
  multiple_instances = {
    vm1 = {
      subnet_id = element(module.vpc.private_subnets, 0)
    }
    vm2 = {
      subnet_id = element(module.vpc.private_subnets, 1)
    }
  }
}
