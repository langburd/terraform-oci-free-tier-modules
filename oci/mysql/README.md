# OCI MySQL Module

Terraform module creating an OCI MySQL HeatWave DB System.

## Always Free Tier Constraints

- Use shape `MySQL.Free` (availability varies by region — check your region's supported shapes)
- Available in home region only
- Single availability domain (is_highly_available must be false)
- 50 GB storage maximum
- Deletion protection is enabled by default (`is_delete_protected`); set it to `false` and apply before a destroy
- Automatic backups are kept for 1 day only; manual backups and point-in-time recovery are not supported
- `backup_is_enabled` and `data_storage_size_in_gb` are not sent for `MySQL.Free` (the API rejects a backup policy for Always Free; storage is fixed at 50 GB)
- OCI upgrades the MySQL version at each maintenance window (`maintenance_window_start_time`)

## Network Access

Pass `nsg_ids` to restrict port 3306 to known sources (the module then also creates the
`<mysql_display_name>-nsg-access` policy that lets the DB system's resource principal create its VNIC
and join the NSGs; without it creation fails with `AuthorizationFailed` even for administrators), and `hostname_label` to give the endpoint a
DNS name (`<hostname_label>.<subnet dns label>.<vcn dns label>.oraclevcn.com`, exposed as `mysql_hostname`).

## Usage Example

```hcl
module "mysql" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/mysql/v1.0.0"

  compartment_id      = "<compartment_ocid>"
  subnet_id           = "<subnet_ocid>"
  availability_domain = "Uocm:PHX-AD-1"
  admin_password      = "<secure_password>"

  shape_name              = "MySQL.Free"
  mysql_display_name      = "my-mysql"
  data_storage_size_in_gb = 50

  nsg_ids                       = ["<nsg_ocid>"]
  hostname_label                = "my-mysql"
  maintenance_window_start_time = "sun 02:00"
  final_backup                  = "REQUIRE_FINAL_BACKUP"
  automatic_backup_retention    = "RETAIN"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 9.0, < 10.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 9.0, < 10.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [oci_identity_policy.nsg](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |
| [oci_mysql_mysql_db_system.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/mysql_mysql_db_system) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Required) The password for the administrative user. The password must be between 8 and 32 characters long, and must contain at least 1 numeric character, 1 lowercase character, 1 uppercase character, and 1 special character. | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | (Optional) The username for the administrative user. | `string` | `"admin"` | no |
| <a name="input_automatic_backup_retention"></a> [automatic\_backup\_retention](#input\_automatic\_backup\_retention) | (Optional) (Updatable) Whether automatic backups are kept or deleted when the DB System is deleted. Supported values: DELETE, RETAIN. Null keeps the OCI default. | `string` | `null` | no |
| <a name="input_availability_domain"></a> [availability\_domain](#input\_availability\_domain) | (Required) The availability domain on which to deploy the Read/Write endpoint. This should be the name of the availability domain (e.g. 'Uocm:PHX-AD-1'). Always Free MySQL is only available in the home region. | `string` | n/a | yes |
| <a name="input_backup_is_enabled"></a> [backup\_is\_enabled](#input\_backup\_is\_enabled) | (Optional) Whether to enable automatic backups for the MySQL DB System. Ignored for MySQL.Free: Always Free systems always take a daily automatic backup (1-day retention) and reject a backup policy. | `bool` | `true` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment where the MySQL DB System will be created. | `string` | n/a | yes |
| <a name="input_data_storage_size_in_gb"></a> [data\_storage\_size\_in\_gb](#input\_data\_storage\_size\_in\_gb) | (Optional) Initial size of the data volume in gigabytes that will be created and attached. Must be <= 50. Ignored for MySQL.Free, whose storage is fixed at 50 GB. | `number` | `50` | no |
| <a name="input_final_backup"></a> [final\_backup](#input\_final\_backup) | (Optional) (Updatable) Whether a final backup is taken when the DB System is deleted. Supported values: SKIP\_FINAL\_BACKUP, REQUIRE\_FINAL\_BACKUP. Null keeps the OCI default. | `string` | `null` | no |
| <a name="input_hostname_label"></a> [hostname\_label](#input\_hostname\_label) | (Optional) Hostname for the DB System's primary endpoint. Together with the subnet and VCN DNS labels it forms the FQDN (e.g. mysql.db.myvcn.oraclevcn.com). Null leaves the endpoint without a DNS name. | `string` | `null` | no |
| <a name="input_is_delete_protected"></a> [is\_delete\_protected](#input\_is\_delete\_protected) | (Optional) (Updatable) Whether the DB System is protected against deletion. Must be set to false (and applied) before the DB System can be destroyed. | `bool` | `true` | no |
| <a name="input_is_highly_available"></a> [is\_highly\_available](#input\_is\_highly\_available) | (Optional) Specifies if the DB System is highly available. Must be false for Always Free tier. | `bool` | `false` | no |
| <a name="input_maintenance_window_start_time"></a> [maintenance\_window\_start\_time](#input\_maintenance\_window\_start\_time) | (Optional) (Updatable) Start of the weekly 2-hour maintenance window, as "{day-of-week} {HH:MM}" in UTC (e.g. "sun 02:00"). Null lets OCI choose. | `string` | `null` | no |
| <a name="input_mysql_defined_tags"></a> [mysql\_defined\_tags](#input\_mysql\_defined\_tags) | (Optional) (Updatable) Defined tags for the MySQL DB System resource. | `map(string)` | `{}` | no |
| <a name="input_mysql_display_name"></a> [mysql\_display\_name](#input\_mysql\_display\_name) | (Optional) (Updatable) The user-friendly name for the MySQL DB System. | `string` | `"mysql"` | no |
| <a name="input_mysql_freeform_tags"></a> [mysql\_freeform\_tags](#input\_mysql\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the MySQL DB System resource. | `map(string)` | `{}` | no |
| <a name="input_network_compartment_id"></a> [network\_compartment\_id](#input\_network\_compartment\_id) | (Optional) OCID of the compartment holding the subnet and NSGs, when it differs from compartment\_id. With nsg\_ids, the resource-principal policy that lets the DB system join its NSGs is created there. | `string` | `null` | no |
| <a name="input_nsg_ids"></a> [nsg\_ids](#input\_nsg\_ids) | (Optional) (Updatable) OCIDs of the Network Security Groups the DB System's endpoint is added to. When set, the module also creates the IAM policy the DB System's resource principal needs to create its VNIC and join the NSGs. | `list(string)` | `[]` | no |
| <a name="input_shape_name"></a> [shape\_name](#input\_shape\_name) | (Optional) The name of the shape. The shape determines the resources allocated to the MySQL DB System. For Always Free, use 'MySQL.Free'. Shape availability varies by region. | `string` | `"MySQL.Free"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) The OCID of the subnet the MySQL DB System is associated with. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_mysql_db_system_id"></a> [mysql\_db\_system\_id](#output\_mysql\_db\_system\_id) | OCID of the MySQL DB System resource. |
| <a name="output_mysql_hostname"></a> [mysql\_hostname](#output\_mysql\_hostname) | Hostname of the primary endpoint of the MySQL DB System (the label or the FQDN, not yet verified against a live DB system). Null unless hostname\_label is set. |
| <a name="output_mysql_ip_address"></a> [mysql\_ip\_address](#output\_mysql\_ip\_address) | The IP address of the primary endpoint of the MySQL DB System. |
| <a name="output_mysql_port"></a> [mysql\_port](#output\_mysql\_port) | The port for primary endpoint of the MySQL DB System to listen on. |
<!-- END_TF_DOCS -->
