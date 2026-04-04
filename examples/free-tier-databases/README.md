# Free Tier Databases Example

This example demonstrates deploying OCI Always Free database resources using the `autonomous_database`, `mysql`, and `nosql` modules together in a single compartment.

## Resources Created

- OCI Compartment (via `identity` module)
- VCN and private subnet (for MySQL networking)
- Autonomous Database (OLTP, Always Free)
- MySQL HeatWave DB System (MySQL.Free shape)
- NoSQL table

## Prerequisites

- OCI CLI configured with a valid profile (`~/.oci/config`)
- Terraform >= 1.6.4
- MySQL.Free shape available in your region

## Usage

```hcl
module "free_tier_databases" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=examples/free-tier-databases/v1.0.0"

  oci_config_profile   = "DEFAULT"
  tenancy_ocid         = "<tenancy_ocid>"
  adb_admin_password   = "<secure_adb_password>"
  mysql_admin_password = "<secure_mysql_password>"
}
```

Or copy this example, create a `terraform.tfvars`:

```hcl
oci_config_profile   = "DEFAULT"
tenancy_ocid         = "ocid1.tenancy.oc1..aaaaaa..."
adb_admin_password   = "YourAdbPassword123#"
mysql_admin_password = "YourMysqlPassword1#"
```

Then run:

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- **MySQL.Free shape**: Availability varies by region. Check with `oci mysql shape list --compartment-id <compartment-ocid>` before applying.
- **Autonomous Database**: Always Free tier auto-stops after 7 days of inactivity and is deleted after 90 days stopped.
- **NoSQL**: Always Free tier allows up to 3 tables with 25 GB and 50 read/write units each.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.37.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_autonomous_database"></a> [autonomous\_database](#module\_autonomous\_database) | ../../oci/autonomous_database | n/a |
| <a name="module_compartment"></a> [compartment](#module\_compartment) | ../../oci/identity | n/a |
| <a name="module_mysql"></a> [mysql](#module\_mysql) | ../../oci/mysql | n/a |
| <a name="module_nosql"></a> [nosql](#module\_nosql) | ../../oci/nosql | n/a |
| <a name="module_oci_profile_reader"></a> [oci\_profile\_reader](#module\_oci\_profile\_reader) | ../../oci/oci_profile_reader | n/a |
| <a name="module_private_subnet"></a> [private\_subnet](#module\_private\_subnet) | ../../oci/subnet | n/a |
| <a name="module_vcn"></a> [vcn](#module\_vcn) | ../../oci/vcn | n/a |

## Resources

| Name | Type |
|------|------|
| [oci_identity_availability_domains.ads](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_availability_domains) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adb_admin_password"></a> [adb\_admin\_password](#input\_adb\_admin\_password) | (Required) The ADMIN user password for the Autonomous Database. Must be 12-30 characters with at least one uppercase, lowercase, and numeric character. | `string` | n/a | yes |
| <a name="input_compartment_name"></a> [compartment\_name](#input\_compartment\_name) | (Optional) Name of the OCI compartment to create for database resources. | `string` | `"free-tier-databases"` | no |
| <a name="input_mysql_admin_password"></a> [mysql\_admin\_password](#input\_mysql\_admin\_password) | (Required) The admin user password for the MySQL DB System. | `string` | n/a | yes |
| <a name="input_oci_config_profile"></a> [oci\_config\_profile](#input\_oci\_config\_profile) | (Required) OCI CLI config file profile name to use for authentication. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autonomous_database_id"></a> [autonomous\_database\_id](#output\_autonomous\_database\_id) | OCID of the Autonomous Database. |
| <a name="output_autonomous_db_name"></a> [autonomous\_db\_name](#output\_autonomous\_db\_name) | The database name of the Autonomous Database. |
| <a name="output_compartment_id"></a> [compartment\_id](#output\_compartment\_id) | OCID of the created compartment. |
| <a name="output_mysql_db_system_id"></a> [mysql\_db\_system\_id](#output\_mysql\_db\_system\_id) | OCID of the MySQL DB System. |
| <a name="output_nosql_table_id"></a> [nosql\_table\_id](#output\_nosql\_table\_id) | OCID of the NoSQL table. |
| <a name="output_nosql_table_name"></a> [nosql\_table\_name](#output\_nosql\_table\_name) | Name of the NoSQL table. |
<!-- END_TF_DOCS -->
