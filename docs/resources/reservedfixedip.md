---
page_title: "gcore_reservedfixedip Resource - terraform-provider-gcore"
subcategory: ""
description: |-
  Represent reserved fixed ips
---

# gcore_reservedfixedip (Resource)

Represent reserved fixed ips

## Example Usage

#### Prerequisite

```terraform
terraform {
  required_providers {
    gcore = {
      source  = "G-Core/gcore"
      version = ">= 0.3.65"
      # source = "local.gcore.com/repo/gcore"
      # version = ">=0.3.64"
    }
  }
  required_version = ">= 0.13.0"
}

provider gcore {
  gcore_cloud_api = "https://cloud-api-preprod.k8s-ed7-2.cloud.gc.onl/"
  permanent_api_token = "369557$4b9bce05a6857f630c3173f37c34a2ace15e5741cb667f944a4ad8fc72af1a70f2c41a27666c459dc4121a0646bde3a28efb76d6b4ddecfa587c8a4b245a6530"
}

data "gcore_project" "project" {
  name = "Default"
}

data "gcore_region" "region" {
  name = "Luxembourg Preprod"
}
```

### Reserving external address

```terraform
resource "gcore_reservedfixedip" "fixed_ip_external" {
  project_id = data.gcore_project.project.id
  region_id  = data.gcore_region.region.id

  type       = "external"

  is_vip     = false
}
```

#### Prerequisite for Private Reserved Fixed IPs

```terraform
resource "gcore_network" "private_network" {
  project_id = data.gcore_project.project.id
  region_id  = data.gcore_region.region.id

  name = "my-private-network"
}

resource "gcore_subnet" "private_subnet" {
  count = 2

  project_id = data.gcore_project.project.id
  region_id  = data.gcore_region.region.id

  network_id = gcore_network.private_network.id
  name       = "${gcore_network.private_network.name}-subnet-${count.index}"

  cidr       = "172.16.${count.index}.0/24"
}
```

### Creating Private Reserved Fixed IP in subnet

```terraform
resource "gcore_reservedfixedip" "fixed_ip_subnet" {
  project_id = data.gcore_project.project.id
  region_id  = data.gcore_region.region.id

  type       = "subnet"
  network_id = gcore_network.private_network.id
  subnet_id = gcore_subnet.private_subnet[0].id

  is_vip     = false
}
```

### Creating Private Reserved Fixed IP in any subnet

```terraform
resource "gcore_reservedfixedip" "fixed_ip_in_any_subnet" {
  project_id = data.gcore_project.project.id
  region_id  = data.gcore_region.region.id

  type       = "any_subnet"
  network_id = gcore_network.private_network.id

  is_vip     = false
}
```

### Creating Private Reserved Fixed IP using ip address

```terraform
locals {
  selected_subnet = gcore_subnet.private_subnet[0]
}

resource "gcore_reservedfixedip" "fixed_ip_ip_address" {
  project_id = data.gcore_project.project.id
  region_id  = data.gcore_region.region.id

  type       = "ip_address"
  network_id = gcore_network.private_network.id
  subnet_id = local.selected_subnet.id

  fixed_ip_address = cidrhost(local.selected_subnet.cidr, 254)

  is_vip     = false
}
```

### Creating Private Reserved Fixed IP using port

```terraform
resource "gcore_loadbalancerv2" "lb" {
  project_id = data.gcore_project.project.id
  region_id  = data.gcore_region.region.id
  name       = "My first public load balancer"
  flavor     = "lb1-1-2"
}

locals {
  preserved_port_id = gcore_loadbalancerv2.lb.vip_port_id
}

resource "gcore_reservedfixedip" "fixed_ip_by_port" {
  project_id = data.gcore_project.project.id
  region_id  = data.gcore_region.region.id

  type       = "port"
  port_id = local.preserved_port_id
}
```

<!-- schema generated by tfplugindocs -->
## Schema

### Required

- `type` (String) Type of the reserved fixed ip for create. Available values are 'external', 'subnet', 'any_subnet', 'ip_address', 'port'

### Optional

- `allowed_address_pairs` (Block List) Group of IP addresses that share the current IP as VIP (see [below for nested schema](#nestedblock--allowed_address_pairs))
- `fixed_ip_address` (String) IP address of the port. Can be passed with type `ip_address` or retrieved after creation.
- `ip_family` (String) IP family of the reserved fixed ip to create. Available values are 'ipv4', 'ipv6', 'dual'
- `is_vip` (Boolean) Flag to indicate whether the port is a virtual IP address.
- `network_id` (String) ID of the desired network. Should be used together with `subnet_id`.
- `port_id` (String) ID of the port underlying the reserved fixed IP. Can be passed with type `port` or retrieved after creation.
- `project_id` (Number) ID of the desired project to create reserved fixed ip in. Alternative for `project_name`. One of them should be specified.
- `project_name` (String) Name of the desired project to create reserved fixed ip in. Alternative for `project_id`. One of them should be specified.
- `region_id` (Number) ID of the desired region to create reserved fixed ip in. Alternative for `region_name`. One of them should be specified.
- `region_name` (String) Name of the desired region to create reserved fixed ip in. Alternative for `region_id`. One of them should be specified.
- `subnet_id` (String) ID of the desired subnet. Can be used together with `network_id`.

### Read-Only

- `fixed_ipv6_address` (String) IPv6 address of the port.
- `id` (String) The ID of this resource.
- `last_updated` (String) Datetime when reserved fixed ip was updated at the last time.
- `status` (String) Underlying port status
- `subnet_v6_id` (String) ID of the IPv6 subnet.

<a id="nestedblock--allowed_address_pairs"></a>
### Nested Schema for `allowed_address_pairs`

Optional:

- `ip_address` (String) IPv4 or IPv6 address.
- `mac_address` (String) MAC address.





## Import

Import is supported using the following syntax:

```shell
# import using <project_id>:<region_id>:<reservedfixedip_id> format
terraform import gcore_reservedfixedip.reservedfixedip1 1:6:447d2959-8ae0-4ca0-8d47-9f050a3637d7
```

