# Two Tenancies Example

This example demonstrates how to manage resources across two Oracle Cloud Infrastructure (OCI) tenancies simultaneously, using profile names read dynamically from environment variables.

## Overview

The configuration reads two OCI profile names from the `OCI_CLI_PROFILE_1` and `OCI_CLI_PROFILE_2` environment variables. Each profile is used to:

- Configure a dedicated OCI provider (via `config_file_profile`)
- Read the tenancy OCID from `~/.oci/config` using the `oci_profile_reader` module
- Create a compartment in that tenancy using the `identity` module

This example is the dynamic counterpart of the [`two-profiles`](../two-profiles) example, which uses hardcoded profile names.

## Prerequisites

- `~/.oci/config` must exist and contain both profiles. Run `oci setup config` to create it.
- Both profiles must include at least `region` and `tenancy` keys.

## Usage

Set the two profile names as environment variables:

```sh
export OCI_CLI_PROFILE_1=your_first_profile
export OCI_CLI_PROFILE_2=your_second_profile
```

Then apply the configuration:

```sh
terraform init
terraform apply
```

## Components

- [`oci_profile_reader`](../../oci/oci_profile_reader): Reads a named OCI profile from `~/.oci/config` and exposes its values as outputs. Used once per tenancy.
- [`identity`](../../oci/identity): Creates a compartment in the specified tenancy. Used once per tenancy.
- OCI providers: Two aliased providers (`tenancy1`, `tenancy2`) are configured in `providers.tf`, each bound to its respective profile.
