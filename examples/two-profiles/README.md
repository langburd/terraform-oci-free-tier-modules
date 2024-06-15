# Two Tenancies Example

This example demonstrates the usage of two Oracle Cloud Infrastructure (OCI) providers and the identity module in a Terraform configuration.

## Overview

The configuration uses two OCI providers, each associated with a different profile (named `profile1` and `profile2`). These profiles are defined in your OCI configuration file (`~/.oci/config`).

The identity module is used to manage resources in each of the two tenancies associated with the profiles.

## Usage

First, ensure that the profiles `profile1` and `profile2` are correctly set up in your OCI configuration file.

Then, you can apply the configuration with the following command:

```sh
terraform apply
```

This will read the data from each profile using the `oci_profile_reader` module and pass it to the `identity` module. The `identity` module will then manage resources in the root compartment of each tenancy.

Here is a brief overview of the main components:

- [oci_profile_reader](../../modules/oci_profile_reader): This module reads an OCI profile and outputs its data. It is used twice in the configuration, once for each profile.

- [identity](../../modules/identity): This module manages resources in an OCI tenancy. It is used twice in the configuration, once for each tenancy.

- OCI providers: Two providers are defined in the `providers.tf` file, each associated with a different profile. These providers are used to authenticate with OCI and manage resources.

For more details, please refer to the source code in the `main.tf`, `providers.tf`, and `outputs.tf` files.
