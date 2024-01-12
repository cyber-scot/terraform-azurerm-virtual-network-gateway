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
      address_space = vpn_client_configuration.value.address_space
      aad_tenant    = vpn_client_configuration.value.aad_tenant_url
      aad_audience  = vpn_client_configuration.value.aad_audience
      aad_issuer    = vpn_client_configuration.value.aad_issuer

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
