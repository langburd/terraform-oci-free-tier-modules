mock_provider "oci" {}

variables {
  compartment_id     = "ocid1.compartment.oc1..aaaaaaaafakecompartmentid"
  vcn_id             = "ocid1.vcn.oc1..aaaaaaaafakevcnid"
  cluster_name       = "test-oke-cluster"
  kubernetes_version = "v1.32.1"
  endpoint_subnet_id = "ocid1.subnet.oc1..aaaaaaaafakesubnetid"
}

run "creates_basic_cluster_with_defaults" {
  command = plan

  assert {
    condition     = oci_containerengine_cluster.this.type == "BASIC_CLUSTER"
    error_message = "Cluster type should default to BASIC_CLUSTER"
  }

  assert {
    condition     = oci_containerengine_cluster.this.endpoint_config != null
    error_message = "Cluster should have an endpoint_config block"
  }
}

run "creates_enhanced_cluster" {
  command = plan

  variables {
    cluster_type = "ENHANCED_CLUSTER"
  }

  assert {
    condition     = oci_containerengine_cluster.this.type == "ENHANCED_CLUSTER"
    error_message = "Cluster type should be ENHANCED_CLUSTER"
  }
}

run "creates_vcn_native_cni_cluster" {
  command = plan

  variables {
    cni_type = "OCI_VCN_IP_NATIVE"
  }

  assert {
    condition     = oci_containerengine_cluster.this.cluster_pod_network_options[0].cni_type == "OCI_VCN_IP_NATIVE"
    error_message = "CNI type should be OCI_VCN_IP_NATIVE"
  }
}

run "creates_private_endpoint" {
  command = plan

  variables {
    endpoint_is_public_ip_enabled = false
  }

  assert {
    condition     = oci_containerengine_cluster.this.endpoint_config[0].is_public_ip_enabled == false
    error_message = "Endpoint should have public IP disabled"
  }
}

run "rejects_invalid_kubernetes_version" {
  command = plan

  variables {
    kubernetes_version = "1.32.1"
  }

  expect_failures = [var.kubernetes_version]
}

run "rejects_invalid_compartment_ocid" {
  command = plan

  variables {
    compartment_id = "not-a-valid-ocid"
  }

  expect_failures = [var.compartment_id]
}

run "rejects_invalid_pods_cidr" {
  command = plan

  variables {
    pods_cidr = "not-a-cidr"
  }

  expect_failures = [var.pods_cidr]
}
