# OCI Autonomous Database Module

Terraform module creating an OCI Always Free Autonomous Database resource.

## Always Free Tier Constraints

- ECPU is fixed at 1 (the API requires compute_count >= 2, but the Always Free tier provides 1 ECPU regardless)
- Storage is fixed at 20 GB
- Auto-stops after 7 days of inactivity; deleted after 90 days stopped
- No private endpoints, no Data Guard, no manual backups
- Maximum 30 concurrent sessions
- Available in home region only

## Usage Example

```hcl
module "autonomous_database" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/autonomous_database/v1.0.0"

  compartment_id = "<compartment_ocid>"
  db_name        = "mydb"
  admin_password = "<secure_password>"

  db_workload  = "OLTP"
  is_free_tier = true
  display_name = "my-autonomous-db"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 8.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_database_autonomous_database.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Required) The password for the ADMIN user. Must be 12 to 30 characters and contain at least one uppercase, one lowercase, and one numeric character. | `string` | n/a | yes |
| <a name="input_autonomous_database_defined_tags"></a> [autonomous\_database\_defined\_tags](#input\_autonomous\_database\_defined\_tags) | (Optional) (Updatable) Defined tags for the Autonomous Database resource. | `map(string)` | `{}` | no |
| <a name="input_autonomous_database_freeform_tags"></a> [autonomous\_database\_freeform\_tags](#input\_autonomous\_database\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the Autonomous Database resource. | `map(string)` | `{}` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment where the Autonomous Database will be created. | `string` | n/a | yes |
| <a name="input_compute_count"></a> [compute\_count](#input\_compute\_count) | (Optional) The number of compute units (ECPUs or OCPUs) for the Autonomous Database. Minimum is 2 per provider API requirements. | `number` | `2` | no |
| <a name="input_compute_model"></a> [compute\_model](#input\_compute\_model) | (Optional) The compute model of the Autonomous Database (ECPU or OCPU). For Always Free, only ECPU is supported. | `string` | `"ECPU"` | no |
| <a name="input_data_storage_size_in_gb"></a> [data\_storage\_size\_in\_gb](#input\_data\_storage\_size\_in\_gb) | (Optional) The size, in gigabytes, of the data volume that will be created and attached to the database. Always Free databases are fixed at 20 GB. | `number` | `20` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | (Required) The database name. Must start with a letter, be alphanumeric only, and be at most 14 characters. | `string` | n/a | yes |
| <a name="input_db_version"></a> [db\_version](#input\_db\_version) | (Optional) A valid Oracle Database version for Autonomous Database. If not specified, the latest version is used. | `string` | `null` | no |
| <a name="input_db_workload"></a> [db\_workload](#input\_db\_workload) | (Optional) (Updatable) The Autonomous Database workload type. Valid values: OLTP, DW, AJD, APEX. | `string` | `"OLTP"` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | (Optional) (Updatable) The user-friendly name for the Autonomous Database. | `string` | `"autonomous-database"` | no |
| <a name="input_is_free_tier"></a> [is\_free\_tier](#input\_is\_free\_tier) | (Optional) Indicates if the database is an Always Free resource. Always Free databases have no additional charges. | `bool` | `true` | no |
| <a name="input_is_mtls_connection_required"></a> [is\_mtls\_connection\_required](#input\_is\_mtls\_connection\_required) | (Optional) (Updatable) Indicates whether the Autonomous Database requires mTLS connections. Set to false to allow TLS connections. | `bool` | `false` | no |
| <a name="input_whitelisted_ips"></a> [whitelisted\_ips](#input\_whitelisted\_ips) | (Optional) (Updatable) The client IP access control list (ACL). This feature is available for databases on shared Exadata infrastructure. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autonomous_database_id"></a> [autonomous\_database\_id](#output\_autonomous\_database\_id) | OCID of the Autonomous Database resource. |
| <a name="output_connection_strings"></a> [connection\_strings](#output\_connection\_strings) | The connection string used to connect to the Autonomous Database. |
| <a name="output_connection_urls"></a> [connection\_urls](#output\_connection\_urls) | The URLs for accessing Oracle Application Express (APEX) and SQL Developer Web with a browser from a Compute instance. |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The database name. |
<!-- END_TF_DOCS -->
