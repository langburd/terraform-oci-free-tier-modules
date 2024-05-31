# Dynamic Profile Example

This example demonstrates how to use different Oracle Cloud Infrastructure (OCI) profiles in a Terraform configuration by exporting the `OCI_CLI_PROFILE` environment variable.

## Overview

The configuration uses the OCI provider and the `oci_profile_reader` module to read data from an OCI profile specified by the `OCI_CLI_PROFILE` environment variable. This data is then used to authenticate with OCI and manage resources.

## Usage

First, ensure that the desired OCI profile is correctly set up in your OCI configuration file (`~/.oci/config`).

Then, set the `OCI_CLI_PROFILE` environment variable to the name of the desired profile:

```sh
export OCI_CLI_PROFILE=your_profile_name
```

After setting the `OCI_CLI_PROFILE` environment variable, you can apply the Terraform configuration with the following command:

```sh
terraform apply
```

This will read the data from the specified profile using the `oci_profile_reader` module and pass it to the OCI provider for authentication.

If the `OCI_CLI_PROFILE` environment variable is not set, the first profile in the OCI configuration file will be used.

Here is a brief overview of the main components:

- `oci_profile_reader`: This module reads an OCI profile and outputs its data.

- OCI provider: The provider is defined in the `providers.tf` file and is used to authenticate with OCI and manage resources.

For more details, please refer to the source code in the `main.tf`, `providers.tf`, and `outputs.tf` files.

Replace `your_profile_name` with the name of the OCI profile you want to use.
