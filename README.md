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

  dynamic "policy_group" {
    for_each = var.policy_group != null ? var.policy_group : null
    content {
      name       = policy_group.value.name
      is_default = policy_group.value.is_default
      priority   = policy_group.value.priority

      dynamic "policy_member" {
        for_each = policy_group.value.policy_member != null ? policy_group.value.policy_member : null
        content {
          name  = policy_member.value.name
          type  = policy_member.value.type
          value = policy_member.value.value
        }
      }
    }
  }

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
      asn         = bgp_settings.value.asn
      peer_weight = bgp_settings.value.peer_weight

      dynamic "peering_addresses" {
        for_each = bgp_settings.value.peering_addresses != null ? bgp_settings.value.peering_addresses : null
        content {
          ip_configuration_name = peering_addresses.value.ip_configuration_name
          apipa_addresses       = peering_addresses.value.apipa_addresses != null ? peering_addresses.value.apipa_addresses : null
        }
      }
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
      address_space         = vpn_client_configuration.value.address_space
      aad_tenant            = vpn_client_configuration.value.aad_tenant_url
      aad_audience          = vpn_client_configuration.value.aad_audience
      aad_issuer            = vpn_client_configuration.value.aad_issuer
      radius_server_address = vpn_client_configuration.value.radius_server_address
      radius_server_secret  = vpn_client_configuration.value.radius_server_secret
      vpn_client_protocols  = vpn_client_configuration.value.vpn_client_protocols
      vpn_auth_types        = vpn_client_configuration.value.vpn_auth_types

      dynamic "virtual_network_gateway_client_connection" {
        for_each = vpn_client_configuration.value.virtual_network_gateway_client_connection
        content {
          name              = virtual_network_gateway_client_connection.value.name
          policy_group_name = virtual_network_gateway_client_connection.value.policy_group_name
          address_prefixes  = virtual_network_gateway_client_connection.value.address_prefixes
        }
      }

      dynamic "radius_server" {
        for_each = vpn_client_configuration.value.radius_server
        content {
          name    = radius_server.value.name
          address = radius_server.value.address
          secret  = radius_server.value.secret
        }
      }

      dynamic "root_certificate" {
        for_each = vpn_client_configuration.value.root_certificate
        content {
          name             = root_certificate.value.name
          public_cert_data = root_certificate.value.data
        }
      }

      dynamic "revoked_certificate" {
        for_each = vpn_client_configuration.value.revoked_certificate
        content {
          name       = revoked_certificate.value.name
          thumbprint = revoked_certificate.value.thumbprint
        }
      }

      dynamic "ipsec_policy" {
        for_each = vpn_client_configuration.value.ipsec_policy
        content {
          sa_life_time_seconds   = ipsec_policy.value.sa_life_time_seconds
          sa_data_size_kilobytes = ipsec_policy.value.sa_data_size_kilobytes
          ipsec_encryption       = ipsec_policy.value.ipsec_encryption
          ipsec_integrity        = ipsec_policy.value.ipsec_integrity
          ike_encryption         = ipsec_policy.value.ike_encryption
          ike_integrity          = ipsec_policy.value.ike_integrity
          dh_group               = ipsec_policy.value.dh_group
          pfs_group              = ipsec_policy.value.pfs_group
        }
      }
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
| <a name="input_bgp_settings"></a> [bgp\_settings](#input\_bgp\_settings) | The BGP settings block, if used | <pre>list(object({<br>    asn = optional(number)<br>    peering_address = optional(list(object({<br>      ip_configuration_name = optional(string)<br>      apipa_addresses       = optional(list(string))<br>    })))<br>    peer_weight = optional(number, 1)<br>  }))</pre> | `[]` | no |
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
| <a name="input_vpn_client_configuration"></a> [vpn\_client\_configuration](#input\_vpn\_client\_configuration) | The VPN client configuration block, if used | <pre>list(object({<br>    address_space  = string<br>    aad_tenant_url = optional(string)<br>    aad_audience   = optional(string)<br>    aad_issuer     = optional(string)<br><br>    ipsec_policy = optional(object({<br>      sa_data_size_kilobytes = number<br>      sa_life_time_seconds   = number<br>      ipsec_encryption       = string<br>      ipsec_integrity        = string<br>      ike_encryption         = string<br>      ike_integrity          = string<br>      dh_group               = string<br>      pfs_group              = string<br>    }))<br>    radius_server = optional(list(object({<br>      address = string<br>      secret  = string<br>      score   = number<br>    })))<br>    radius_server_address = optional(string)<br>    radius_server_secret  = optional(string)<br>    root_certificate = optional(list(object({<br>      name             = string<br>      public_cert_data = string<br>    })))<br>    revoked_certificate = optional(list(object({<br>      name       = string<br>      thumbprint = string<br>    })))<br>    vpn_client_protocols = optional(list(string))<br>    vpn_auth_type        = optional(list(string))<br>    virtual_network_gateway_client_connection = optional(list(object({<br>      name              = string<br>      policy_group_name = list(string)<br>      address_prefixes  = list(string)<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_vpn_type"></a> [vpn\_type](#input\_vpn\_type) | The VPN type, can either be RouteBased or PolicyBased | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | The actual IP address of the Public IP. |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | The ID of the Public IP. |
| <a name="output_public_ip_name"></a> [public\_ip\_name](#output\_public\_ip\_name) | The name of the Public IP. |
| <a name="output_virtual_network_gateway_bgp_peering_addresses"></a> [virtual\_network\_gateway\_bgp\_peering\_addresses](#output\_virtual\_network\_gateway\_bgp\_peering\_addresses) | A list of peering\_addresses for the BGP peer of the Virtual Network Gateway. |
| <a name="output_virtual_network_gateway_bgp_settings"></a> [virtual\_network\_gateway\_bgp\_settings](#output\_virtual\_network\_gateway\_bgp\_settings) | A block of bgp\_settings of the Virtual Network Gateway. |
| <a name="output_virtual_network_gateway_default_addresses"></a> [virtual\_network\_gateway\_default\_addresses](#output\_virtual\_network\_gateway\_default\_addresses) | A list of peering address assigned to the BGP peer of the Virtual Network Gateway. |
| <a name="output_virtual_network_gateway_id"></a> [virtual\_network\_gateway\_id](#output\_virtual\_network\_gateway\_id) | The ID of the Virtual Network Gateway. |
| <a name="output_virtual_network_gateway_tunnel_ip_addresses"></a> [virtual\_network\_gateway\_tunnel\_ip\_addresses](#output\_virtual\_network\_gateway\_tunnel\_ip\_addresses) | A list of tunnel IP addresses assigned to the BGP peer of the Virtual Network Gateway. |
