# --- Tenancy 1 ---

module "oci_profile_reader1" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.profile1
}

module "compartment1" {
  source               = "../../oci/identity"
  oci_root_compartment = module.oci_profile_reader1.oci_profile_data.tenancy
  compartment_name     = "tenancy1-compartment"

  providers = {
    oci = oci.tenancy1
  }
}

module "budget1" {
  source                = "../../oci/budget"
  budget_compartment_id = module.oci_profile_reader1.oci_profile_data.tenancy
  budget_targets        = [module.oci_profile_reader1.oci_profile_data.tenancy]
  budget_amount         = var.budget_amount
  alert_recipients      = var.alert_recipients

  providers = {
    oci = oci.tenancy1
  }
}

# --- Tenancy 2 ---

module "oci_profile_reader2" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.profile2
}

module "compartment2" {
  source               = "../../oci/identity"
  oci_root_compartment = module.oci_profile_reader2.oci_profile_data.tenancy
  compartment_name     = "tenancy2-compartment"

  providers = {
    oci = oci.tenancy2
  }
}

module "budget2" {
  source                = "../../oci/budget"
  budget_compartment_id = module.oci_profile_reader2.oci_profile_data.tenancy
  budget_targets        = [module.oci_profile_reader2.oci_profile_data.tenancy]
  budget_amount         = var.budget_amount
  alert_recipients      = var.alert_recipients

  providers = {
    oci = oci.tenancy2
  }
}
