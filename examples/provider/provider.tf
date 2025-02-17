terraform {
  required_version = ">= 0.13.0"
  required_providers {
    gcore = {
      source  = "G-Core/gcore"
      version = ">= 0.3.70"
    }
  }
}

provider gcore {
  permanent_api_token = "251$d3361.............1b35f26d8"
}

variable "project_id" {
  type    = number
  default = 1
}

variable "region_id" {
  type    = number
  default = 76
}

resource "gcore_keypair" "kp" {
  project_id  = var.project_id
  public_key  = "ssh-ed25519 AAAA...CjZ user@example.com"
  sshkey_name = "test_key"
}

resource "gcore_network" "network" {
  name       = "test_network"
  type       = "vxlan"
  region_id  = var.region_id
  project_id = var.project_id
}

resource "gcore_subnet" "subnet" {
  name            = "test_subnet"
  cidr            = "192.168.10.0/24"
  network_id      = gcore_network.network.id
  dns_nameservers = ["8.8.4.4", "1.1.1.1"]

  region_id  = var.region_id
  project_id = var.project_id
}

resource "gcore_subnet" "subnet2" {
  name            = "test_subnet_2"
  cidr            = "192.168.20.0/24"
  network_id      = gcore_network.network.id
  dns_nameservers = ["8.8.4.4", "1.1.1.1"]
  region_id       = var.region_id
  project_id      = var.project_id
}

resource "gcore_volume" "first_volume" {
  name       = "test_boot_volume_1"
  type_name  = "ssd_hiiops"
  image_id   = "8f0900ba-2002-4f79-b866-390444caa19e"
  size       = 10
  region_id  = var.region_id
  project_id = var.project_id
}

resource "gcore_volume" "second_volume" {
  name       = "test_boot_volume_2"
  type_name  = "ssd_hiiops"
  image_id   = "8f0900ba-2002-4f79-b866-390444caa19e"
  size       = 10
  region_id  = var.region_id
  project_id = var.project_id
}

resource "gcore_volume" "third_volume" {
  name = "test_data_volume"
  type_name = "ssd_hiiops"
  size = 6
  region_id = var.region_id
  project_id = var.project_id
}

resource "gcore_instancev2" "instance" {
  flavor_id    = "g1-standard-2-4"
  name         = "test_instance_1"
  keypair_name = gcore_keypair.kp.sshkey_name

  volume {
    source     = "existing-volume"
    volume_id  = gcore_volume.first_volume.id
    boot_index = 0
  }

  interface {
    type       = "subnet"
    network_id = gcore_network.network.id
    subnet_id  = gcore_subnet.subnet.id
    security_groups = ["11384ae2-2677-439c-8618-f350da006163"]
  }

  interface {
    type            = "subnet"
    network_id      = gcore_network.network.id
    subnet_id       = gcore_subnet.subnet2.id
    security_groups = ["11384ae2-2677-439c-8618-f350da006163"]
  }

  metadata_map = {
    owner = "username"
  }

  region_id  = var.region_id
  project_id = var.project_id
}

resource "gcore_loadbalancerv2" "lb" {
  project_id = var.project_id
  region_id  = var.region_id
  name       = "test_loadbalancer"
  flavor     = "lb1-1-2"
}

resource "gcore_lblistener" "listener" {
  project_id      = var.project_id
  region_id       = var.region_id
  name            = "test_listener"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = gcore_loadbalancerv2.lb.id
}

resource "gcore_lbpool" "pl" {
  project_id      = var.project_id
  region_id       = var.region_id
  name            = "test_pool"
  protocol        = "HTTP"
  lb_algorithm    = "LEAST_CONNECTIONS"
  loadbalancer_id = gcore_loadbalancerv2.lb.id
  listener_id     = gcore_lblistener.listener.id
  health_monitor {
    type        = "PING"
    delay       = 60
    max_retries = 5
    timeout     = 10
  }
}

resource "gcore_lbmember" "lbm" {
  project_id    = var.project_id
  region_id     = var.region_id
  pool_id       = gcore_lbpool.pl.id
  instance_id   = gcore_instancev2.instance.id
  address       = tolist(gcore_instancev2.instance.interface).0.ip_address
  protocol_port = 8081
}

resource "gcore_instancev2" "instance2" {
  flavor_id    = "g1-standard-2-4"
  name         = "test_instance_2"
  keypair_name = gcore_keypair.kp.sshkey_name

  volume {
    source     = "existing-volume"
    volume_id  = gcore_volume.second_volume.id
    boot_index = 0
  }

  volume {
    source = "existing-volume"
    volume_id = gcore_volume.third_volume.id
    boot_index = 1
  }

  interface {
    type            = "subnet"
    network_id      = gcore_network.network.id
    subnet_id       = gcore_subnet.subnet.id
    security_groups = ["11384ae2-2677-439c-8618-f350da006163"]
  }

  metadata_map = {
    owner = "username"
  }

  region_id  = var.region_id
  project_id = var.project_id
}

resource "gcore_lbmember" "lbm2" {
  project_id    = var.project_id
  region_id     = var.region_id
  pool_id       = gcore_lbpool.pl.id
  instance_id   = gcore_instancev2.instance2.id
  address       = tolist(gcore_instancev2.instance2.interface).0.ip_address
  protocol_port = 8081
  weight        = 5
}
