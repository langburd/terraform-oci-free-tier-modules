module "compartment" {
  source               = "../../modules/identity"
  oci_root_compartment = local.oci_profile_data.tenancy
}
