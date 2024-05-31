# Get data from the profile1 and pass it to the identity module
module "oci_profile_reader1" {
  source       = "../../modules/oci_profile_reader"
  profile_name = "profile1"
}

module "compartment1" {
  source               = "../../modules/identity"
  oci_root_compartment = module.oci_profile_reader1.oci_profile_data.tenancy

  providers = {
    oci = oci.profile1
  }

}

# Get data from the profile2 and pass it to the identity module
module "oci_profile_reader2" {
  source       = "../../modules/oci_profile_reader"
  profile_name = "profile2"
}

module "compartment2" {
  source               = "../../modules/identity"
  oci_root_compartment = module.oci_profile_reader2.oci_profile_data.tenancy

  providers = {
    oci = oci.profile2
  }
}
