resource "azurerm_public_ip" "pip" {
  count = var.create_public_ip == true ? 1 : 0

  name                = var.public_ip_name != null ? var.public_ip_name : "pip-${var.name}"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = var.public_ip_allocation_method != null ? var.public_ip_allocation_method : "Static"
  sku                 = var.public_ip_sku != null ? var.public_ip_sku : "Standard"
  tags                = var.tags

}

resource "azurerm_virtual_network_gateway" "vnet_gw" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  type                                  = var.type
  vpn_type                              = var.vpn_type
  sku                                   = var.sku
  active_active                         = var.sku == "HighPerformance" || var.sku == "UltraPerformance" ? var.active_active : false
  enable_bgp                            = var.enable_bgp
  default_local_network_gateway_id      = var.default_local_network_gateway_id != null ? var.default_local_network_gateway_id : null
  edge_zone                             = var.edge_zone != null ? var.edge_zone : null
  generation                            = var.generation
  private_ip_address_enabled            = var.private_ip_address_enabled != null ? var.private_ip_address_enabled : false
  dns_forwarding_enabled                = var.dns_forwarding_enabled != null ? var.dns_forwarding_enabled : false
  bgp_route_translation_for_nat_enabled = var.bgp_route_translation_for_nat_enabled != null ? var.bgp_route_translation_for_nat_enabled : false
  ip_sec_replay_protection_enabled      = var.ip_sec_replay_protection_enabled != null ? var.ip_sec_replay_protection_enabled : false
  remote_vnet_traffic_enabled           = var.remote_vnet_traffic_enabled != null ? var.remote_vnet_traffic_enabled : false
  virtual_wan_traffic_enabled           = var.virtual_wan_traffic_enabled != null ? var.virtual_wan_traffic_enabled : false

  dynamic "ip_configuration" {
    for_each = var.ip_configuration != null ? var.ip_configuration : null
    content {
      name                          = ip_configuration.value.name != null ? ip_configuration.value.name : "ipconfig-${var.name}"
      public_ip_address_id          = var.create_public_ip == true ? azurerm_public_ip.pip[0].id : ip_configuration.value.public_ip_address_id
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation != null ? ip_configuration.value.private_ip_address_allocation : "Dynamic"
      subnet_id                     = ip_configuration.value.subnet_id
    }
  }

  dynamic "bgp_settings" {
    for_each = var.bgp_settings != null ? var.bgp_settings : null
    content {
      asn             = bgp_settings.value.asn
      peering_address = bgp_settings.value.bgp_peering_address
      peer_weight     = bgp_settings.value.peer_weight
    }
  }

  dynamic "custom_route" {
    for_each = var.custom_route != null ? var.custom_route : null
    content {
      address_prefixes = custom_route.value.address_prefixes
    }
  }

  dynamic "vpn_client_configuration" {
    for_each = var.vpn_client_configuration
    content {
      address_space = vpn_client_configuration.value.address_space
      aad_tenant    = vpn_client_configuration.value.aad_tenant_url
      aad_audience  = vpn_client_configuration.value.aad_audience
      aad_issuer    = vpn_client_configuration.value.aad_issuer
    }
  }

  vpn_client_configuration {
    address_space = ["10.2.0.0/24"]

    root_certificate {
      name = "DigiCert-Federated-ID-Root-CA"

      public_cert_data = <<EOF
MIIDuzCCAqOgAwIBAgIQCHTZWCM+IlfFIRXIvyKSrjANBgkqhkiG9w0BAQsFADBn
MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
d3cuZGlnaWNlcnQuY29tMSYwJAYDVQQDEx1EaWdpQ2VydCBGZWRlcmF0ZWQgSUQg
Um9vdCBDQTAeFw0xMzAxMTUxMjAwMDBaFw0zMzAxMTUxMjAwMDBaMGcxCzAJBgNV
BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
Y2VydC5jb20xJjAkBgNVBAMTHURpZ2lDZXJ0IEZlZGVyYXRlZCBJRCBSb290IENB
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvAEB4pcCqnNNOWE6Ur5j
QPUH+1y1F9KdHTRSza6k5iDlXq1kGS1qAkuKtw9JsiNRrjltmFnzMZRBbX8Tlfl8
zAhBmb6dDduDGED01kBsTkgywYPxXVTKec0WxYEEF0oMn4wSYNl0lt2eJAKHXjNf
GTwiibdP8CUR2ghSM2sUTI8Nt1Omfc4SMHhGhYD64uJMbX98THQ/4LMGuYegou+d
GTiahfHtjn7AboSEknwAMJHCh5RlYZZ6B1O4QbKJ+34Q0eKgnI3X6Vc9u0zf6DH8
Dk+4zQDYRRTqTnVO3VT8jzqDlCRuNtq6YvryOWN74/dq8LQhUnXHvFyrsdMaE1X2
DwIDAQABo2MwYTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNV
HQ4EFgQUGRdkFnbGt1EWjKwbUne+5OaZvRYwHwYDVR0jBBgwFoAUGRdkFnbGt1EW
jKwbUne+5OaZvRYwDQYJKoZIhvcNAQELBQADggEBAHcqsHkrjpESqfuVTRiptJfP
9JbdtWqRTmOf6uJi2c8YVqI6XlKXsD8C1dUUaaHKLUJzvKiazibVuBwMIT84AyqR
QELn3e0BtgEymEygMU569b01ZPxoFSnNXc7qDZBDef8WfqAV/sxkTi8L9BkmFYfL
uGLOhRJOFprPdoDIUBB+tmCl3oDcBy3vnUeOEioz8zAkprcb3GHwHAK+vHmmfgcn
WsfMLH4JCLa/tRYL+Rw/N3ybCkDp00s0WUZ+AoDywSl0Q/ZEnNY0MsFiw6LyIdbq
M/s/1JRtO3bDSzD9TazRVzn2oBqzSa8VgIo5C1nOnoAKJTlsClJKvIhnRlaLQqk=
EOF

    }

    revoked_certificate {
      name       = "Verizon-Global-Root-CA"
      thumbprint = "912198EEF23DCAC40939312FEE97DD560BAE49B1"
    }
  }
}
