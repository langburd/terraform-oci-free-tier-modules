# OCI MySQL Module

Terraform module creating an OCI MySQL HeatWave DB System.

## Always Free Tier Constraints

- Use shape `MySQL.Free` (availability varies by region — check your region's supported shapes)
- Available in home region only
- Single availability domain (is_highly_available must be false)
- 50 GB storage maximum
- Deletion protection is enabled by default

## Usage Example

```hcl
module "mysql" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/mysql/v1.0.0"

  compartment_id      = "<compartment_ocid>"
  subnet_id           = "<subnet_ocid>"
  availability_domain = "Uocm:PHX-AD-1"
  admin_password      = "<secure_password>"

  shape_name             = "MySQL.Free"
  mysql_display_name     = "my-mysql"
  data_storage_size_in_gb = 50
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
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_mysql_mysql_db_system.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/mysql_mysql_db_system) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Required) The password for the administrative user. The password must be between 8 and 32 characters long, and must contain at least 1 numeric character, 1 lowercase character, 1 uppercase character, and 1 special character. | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | (Optional) The username for the administrative user. | `string` | `"admin"` | no |
| <a name="input_availability_domain"></a> [availability\_domain](#input\_availability\_domain) | (Required) The availability domain on which to deploy the Read/Write endpoint. This should be the name of the availability domain (e.g. 'Uocm:PHX-AD-1'). Always Free MySQL is only available in the home region. | `string` | n/a | yes |
| <a name="input_backup_is_enabled"></a> [backup\_is\_enabled](#input\_backup\_is\_enabled) | (Optional) Whether to enable automatic backups for the MySQL DB System. | `bool` | `true` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment where the MySQL DB System will be created. | `string` | n/a | yes |
| <a name="input_data_storage_size_in_gb"></a> [data\_storage\_size\_in\_gb](#input\_data\_storage\_size\_in\_gb) | (Optional) Initial size of the data volume in gigabytes that will be created and attached. Must be <= 50 for Always Free tier. | `number` | `50` | no |
| <a name="input_is_highly_available"></a> [is\_highly\_available](#input\_is\_highly\_available) | (Optional) Specifies if the DB System is highly available. Must be false for Always Free tier. | `bool` | `false` | no |
| <a name="input_mysql_defined_tags"></a> [mysql\_defined\_tags](#input\_mysql\_defined\_tags) | (Optional) (Updatable) Defined tags for the MySQL DB System resource. | `map(string)` | `{}` | no |
| <a name="input_mysql_display_name"></a> [mysql\_display\_name](#input\_mysql\_display\_name) | (Optional) (Updatable) The user-friendly name for the MySQL DB System. | `string` | `"mysql"` | no |
| <a name="input_mysql_freeform_tags"></a> [mysql\_freeform\_tags](#input\_mysql\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the MySQL DB System resource. | `map(string)` | `{}` | no |
| <a name="input_shape_name"></a> [shape\_name](#input\_shape\_name) | (Optional) The name of the shape. The shape determines the resources allocated to the MySQL DB System. For Always Free, use 'MySQL.Free'. Shape availability varies by region. | `string` | `"MySQL.Free"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) The OCID of the subnet the MySQL DB System is associated with. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mysql_db_system_id"></a> [mysql\_db\_system\_id](#output\_mysql\_db\_system\_id) | OCID of the MySQL DB System resource. |
| <a name="output_mysql_ip_address"></a> [mysql\_ip\_address](#output\_mysql\_ip\_address) | The IP address of the primary endpoint of the MySQL DB System. |
| <a name="output_mysql_port"></a> [mysql\_port](#output\_mysql\_port) | The port for primary endpoint of the MySQL DB System to listen on. |
<!-- END_TF_DOCS -->
