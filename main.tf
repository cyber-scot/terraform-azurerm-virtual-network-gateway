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
  default_local_network_gateway_id      = var.create_local_network_gateway == true ? azurerm_local_network_gateway.local_gw[0].id : var.default_local_network_gateway_id
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
          name               = virtual_network_gateway_client_connection.value.name
          policy_group_names = virtual_network_gateway_client_connection.value.policy_group_name
          address_prefixes   = virtual_network_gateway_client_connection.value.address_prefixes
        }
      }

      dynamic "radius_server" {
        for_each = vpn_client_configuration.value.radius_server
        content {
          score   = radius_server.value.score
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
          sa_lifetime_in_seconds    = ipsec_policy.value.sa_lifetime_in_seconds
          sa_data_size_in_kilobytes = ipsec_policy.value.sa_data_size_in_kilobytes
          ipsec_encryption          = ipsec_policy.value.ipsec_encryption
          ipsec_integrity           = ipsec_policy.value.ipsec_integrity
          ike_encryption            = ipsec_policy.value.ike_encryption
          ike_integrity             = ipsec_policy.value.ike_integrity
          dh_group                  = ipsec_policy.value.dh_group
          pfs_group                 = ipsec_policy.value.pfs_group
        }
      }
    }
  }
}


resource "azurerm_local_network_gateway" "local_gw" {
  count               = var.create_local_network_gateway == true ? 1 : 0
  name                = var.local_network_gateway_name != null ? var.local_network_gateway_name : "local-gw-${var.name}"
  resource_group_name = var.rg_name
  location            = var.location
  gateway_address     = var.local_network_gateway_fqdn == null ? var.gateway_address : null
  gateway_fqdn        = var.local_network_gateway_address == null ? var.gateway_fqdn : null
  address_space       = var.local_network_gateway_address_space

  dynamic "bgp_settings" {
    for_each = var.local_network_gateway_bgp_settings
    content {
      asn                 = bgp_settings.value.asn
      bgp_peering_address = bgp_settings.value.bgp_peering_address
      peer_weight         = bgp_settings.value.peer_weight
    }
  }
}
