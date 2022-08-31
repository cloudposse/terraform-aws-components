module "dms_replication_instance" {
  source  = "cloudposse/dms/aws//modules/dms-replication-instance"
  version = "0.1.1"

  # https://docs.aws.amazon.com/dms/latest/userguide/CHAP_ReleaseNotes.html
  engine_version               = var.engine_version
  replication_instance_class   = var.replication_instance_class
  allocated_storage            = var.allocated_storage
  apply_immediately            = var.apply_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  allow_major_version_upgrade  = var.allow_major_version_upgrade
  multi_az                     = var.multi_az
  publicly_accessible          = var.publicly_accessible
  preferred_maintenance_window = var.preferred_maintenance_window
  vpc_security_group_ids       = [module.security_group.id]
  subnet_ids                   = module.vpc.outputs.private_subnet_ids
  availability_zone            = var.availability_zone

  context = module.this.context
}
