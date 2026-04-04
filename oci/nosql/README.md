# OCI NoSQL Module

Terraform module creating an OCI NoSQL Database table with optional indexes.

## Always Free Tier Constraints

- Maximum 3 tables per tenancy
- Up to 50 read/write units per table
- Up to 25 GB storage per table
- DDL statement updates must preserve existing column order

## Usage Example

```hcl
module "nosql" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/nosql/v1.0.0"

  compartment_id = "<compartment_ocid>"
  table_name     = "my_table"
  ddl_statement  = "CREATE TABLE my_table (id INTEGER, name STRING, PRIMARY KEY(id))"

  table_limits_max_read_units     = 50
  table_limits_max_write_units    = 50
  table_limits_max_storage_in_gbs = 25

  indexes = {
    name_idx = {
      keys = [
        { column_name = "name" }
      ]
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 6.0, < 7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_nosql_index.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/nosql_index) | resource |
| [oci_nosql_table.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/nosql_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment where the NoSQL table will be created. | `string` | n/a | yes |
| <a name="input_ddl_statement"></a> [ddl\_statement](#input\_ddl\_statement) | (Required) Represents the table schema information as a DDL statement, e.g. 'CREATE TABLE foo (id INTEGER, name STRING, PRIMARY KEY(id))'. | `string` | n/a | yes |
| <a name="input_indexes"></a> [indexes](#input\_indexes) | (Optional) A map of indexes to create on the table. Each index must specify a list of key columns. | <pre>map(object({<br/>    keys = list(object({<br/>      column_name     = string<br/>      json_field_type = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_nosql_defined_tags"></a> [nosql\_defined\_tags](#input\_nosql\_defined\_tags) | (Optional) (Updatable) Defined tags for the NoSQL table resource. | `map(string)` | `{}` | no |
| <a name="input_nosql_freeform_tags"></a> [nosql\_freeform\_tags](#input\_nosql\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the NoSQL table resource. | `map(string)` | `{}` | no |
| <a name="input_table_limits_max_read_units"></a> [table\_limits\_max\_read\_units](#input\_table\_limits\_max\_read\_units) | (Optional) (Updatable) Maximum number of read units for the table. Valid range: 1-50. | `number` | `50` | no |
| <a name="input_table_limits_max_storage_in_gbs"></a> [table\_limits\_max\_storage\_in\_gbs](#input\_table\_limits\_max\_storage\_in\_gbs) | (Optional) (Updatable) Maximum storage capacity in gigabytes for the table. Valid range: 1-25. | `number` | `25` | no |
| <a name="input_table_limits_max_write_units"></a> [table\_limits\_max\_write\_units](#input\_table\_limits\_max\_write\_units) | (Optional) (Updatable) Maximum number of write units for the table. Valid range: 1-50. | `number` | `50` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | (Required) A user-friendly name for the table. Table name must contain only letters, numbers, and underscores. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_table_id"></a> [table\_id](#output\_table\_id) | OCID of the NoSQL table resource. |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | The name of the NoSQL table. |
<!-- END_TF_DOCS -->
