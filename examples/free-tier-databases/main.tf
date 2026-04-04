locals {
  oci_profile_data = module.oci_profile_reader.oci_profile_data
}

module "oci_profile_reader" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.oci_config_profile
}

module "compartment" {
  source               = "../../oci/identity"
  oci_root_compartment = local.oci_profile_data.tenancy
  compartment_name     = var.compartment_name
}

# VCN and subnet required by MySQL DB System
module "vcn" {
  source           = "../../oci/vcn"
  compartment_id   = module.compartment.compartment_id
  vcn_display_name = "free-tier-databases-vcn"
  vcn_cidr_blocks  = ["10.0.0.0/16"]
}

module "private_subnet" {
  source                    = "../../oci/subnet"
  compartment_id            = module.compartment.compartment_id
  vcn_id                    = module.vcn.vcn_id
  subnet_cidr_block         = "10.0.1.0/24"
  subnet_display_name       = "databases-private-subnet"
  prohibit_internet_ingress = true
}

# Always Free Autonomous Database (OLTP workload)
module "autonomous_database" {
  source = "../../oci/autonomous_database"

  compartment_id = module.compartment.compartment_id
  db_name        = "freetieradb"
  admin_password = var.adb_admin_password

  db_workload  = "OLTP"
  is_free_tier = true
  display_name = "free-tier-adb"

  autonomous_database_freeform_tags = {
    "example" = "free-tier-databases"
  }
}

# Always Free MySQL DB System
# Note: MySQL.Free shape availability varies by region.
# Run: oci mysql shape list --compartment-id <compartment-ocid>
# to confirm MySQL.Free is available in your region.
module "mysql" {
  source = "../../oci/mysql"

  compartment_id      = module.compartment.compartment_id
  subnet_id           = module.private_subnet.subnet_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  admin_password      = var.mysql_admin_password

  shape_name         = "MySQL.Free"
  mysql_display_name = "free-tier-mysql"

  mysql_freeform_tags = {
    "example" = "free-tier-databases"
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = local.oci_profile_data.tenancy
}

# NoSQL table for schema-less data
module "nosql" {
  source = "../../oci/nosql"

  compartment_id = module.compartment.compartment_id
  table_name     = "free_tier_table"
  ddl_statement  = "CREATE TABLE free_tier_table (id INTEGER, data JSON, PRIMARY KEY(id))"

  nosql_freeform_tags = {
    "example" = "free-tier-databases"
  }
}
