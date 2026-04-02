# Get profile data for the first tenancy
module "oci_profile_reader1" {
  source       = "../../oci/oci_profile_reader"
  profile_name = data.env_variable.profile1.value
}

module "compartment1" {
  source = "../../oci/identity"

  oci_root_compartment    = module.oci_profile_reader1.oci_profile_data.tenancy
  compartment_name        = "TENANCY1-Compartment"
  compartment_description = "This is a compartment for the first tenancy"

  providers = {
    oci = oci.tenancy1
  }
}

# Get profile data for the second tenancy
module "oci_profile_reader2" {
  source       = "../../oci/oci_profile_reader"
  profile_name = data.env_variable.profile2.value
}

module "compartment2" {
  source = "../../oci/identity"

  oci_root_compartment    = module.oci_profile_reader2.oci_profile_data.tenancy
  compartment_name        = "TENANCY2-Compartment"
  compartment_description = "This is a compartment for the second tenancy"

  providers = {
    oci = oci.tenancy2
  }
}
