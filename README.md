```hcl
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
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_network_gateway.vnet_gw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_active_active"></a> [active\_active](#input\_active\_active) | Whether to create an active-active gateway or not | `bool` | `false` | no |
| <a name="input_bgp_route_translation_for_nat_enabled"></a> [bgp\_route\_translation\_for\_nat\_enabled](#input\_bgp\_route\_translation\_for\_nat\_enabled) | Whether BGP route transaltion for NAT is enabled on the VNet gateway | `bool` | `false` | no |
| <a name="input_bgp_settings"></a> [bgp\_settings](#input\_bgp\_settings) | The BGP settings block, if used | <pre>list(object({<br>    asn             = optional(number)<br>    peering_address = optional(list(string))<br>    peer_weight     = optional(number, 1)<br>  }))</pre> | `[]` | no |
| <a name="input_create_public_ip"></a> [create\_public\_ip](#input\_create\_public\_ip) | Whether to create a public IP, or bring your own | `bool` | `true` | no |
| <a name="input_custom_route"></a> [custom\_route](#input\_custom\_route) | The custom route block, if used | <pre>list(object({<br>    address_prefixes = optional(list(string))<br>  }))</pre> | `[]` | no |
| <a name="input_default_local_network_gateway_id"></a> [default\_local\_network\_gateway\_id](#input\_default\_local\_network\_gateway\_id) | The ID of the default local network gateway | `string` | `null` | no |
| <a name="input_dns_forwarding_enabled"></a> [dns\_forwarding\_enabled](#input\_dns\_forwarding\_enabled) | Whether DNS forwarding is enabled on the VNet gateway | `bool` | `true` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | The edge zone for the VNet to be deployed | `string` | `null` | no |
| <a name="input_enable_bgp"></a> [enable\_bgp](#input\_enable\_bgp) | Whether BGP should be enabled on the VNet gateway | `bool` | `false` | no |
| <a name="input_generation"></a> [generation](#input\_generation) | The generation of the VNet gateway, can either be Generation1 or Generation2 or None | `string` | `"Generation2"` | no |
| <a name="input_ip_configuration"></a> [ip\_configuration](#input\_ip\_configuration) | The IP configuration block of the VNet gateway | <pre>list(object({<br>    name                          = optional(string),<br>    public_ip_address_id          = optional(string)<br>    private_ip_address_allocation = optional(string, "Dynamic")<br>    subnet_id                     = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_ip_sec_replay_protection_enabled"></a> [ip\_sec\_replay\_protection\_enabled](#input\_ip\_sec\_replay\_protection\_enabled) | Whether IP Sec replay protection is enabled on the VNet gateway | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the VNet gateway | `string` | n/a | yes |
| <a name="input_policy_group"></a> [policy\_group](#input\_policy\_group) | The policy group block, if used | <pre>list(object({<br>    name = string<br>    policy_member = list(object({<br>      name  = string<br>      type  = string<br>      value = string<br>    }))<br>    is_default = optional(bool, false)<br>    priority   = optional(number, 0)<br>  }))</pre> | `[]` | no |
| <a name="input_private_ip_address_enabled"></a> [private\_ip\_address\_enabled](#input\_private\_ip\_address\_enabled) | Whether private IP address is enabled on the VNet gateway | `bool` | `false` | no |
| <a name="input_public_ip_allocation_method"></a> [public\_ip\_allocation\_method](#input\_public\_ip\_allocation\_method) | The allocation method of the public ip | `string` | `null` | no |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | The name of the public IP | `string` | `null` | no |
| <a name="input_public_ip_sku"></a> [public\_ip\_sku](#input\_public\_ip\_sku) | The sku of the public ip | `string` | `null` | no |
| <a name="input_remote_vnet_traffic_enabled"></a> [remote\_vnet\_traffic\_enabled](#input\_remote\_vnet\_traffic\_enabled) | Whether remote VNet traffic is enabled on the VNet gateway | `bool` | `false` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the VNet gateway | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | The type of VPN gateway to create, either Vpn or ExpressRoute | `string` | n/a | yes |
| <a name="input_virtual_wan_traffic_enabled"></a> [virtual\_wan\_traffic\_enabled](#input\_virtual\_wan\_traffic\_enabled) | Whether virtual wan traffic is enabled on the VNet gateway | `bool` | `false` | no |
| <a name="input_vpn_client_configuration"></a> [vpn\_client\_configuration](#input\_vpn\_client\_configuration) | The VPN client configuration block, if used | <pre>list(object({<br>    address_space  = string<br>    aad_tenant_url = optional(string)<br>    aad_audience   = optional(string)<br>    aad_issuer     = optional(string)<br><br>    ip_sec_policy = optional(object({<br>      sa_data_size_kilobytes = number<br>      sa_life_time_seconds   = number<br>      ipsec_encryption       = string<br>      ipsec_integrity        = string<br>      ike_encryption         = string<br>      ike_integrity          = string<br>      dh_group               = string<br>      pfs_group              = string<br>    }))<br>    radius_server = optional(list(object({<br>      address = string<br>      secret  = string<br>      score   = number<br>    })))<br>    radius_server_address = optional(string)<br>    radius_server_secret  = optional(string)<br>    vpn_client_protocols  = optional(list(string))<br>    vpn_auth_type         = optional(list(string))<br>    virtual_network_gateway_client_connection = optional(list(object({<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_vpn_type"></a> [vpn\_type](#input\_vpn\_type) | The VPN type, can either be RouteBased or PolicyBased | `string` | n/a | yes |

## Outputs

No outputs.
