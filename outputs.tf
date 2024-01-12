output "public_ip_address" {
  description = "The actual IP address of the Public IP."
  value       = var.create_public_ip == true ? azurerm_public_ip.pip[0].ip_address : ""
}

output "public_ip_id" {
  description = "The ID of the Public IP."
  value       = var.create_public_ip == true ? azurerm_public_ip.pip[0].id : ""
}

output "public_ip_name" {
  description = "The name of the Public IP."
  value       = var.create_public_ip == true ? azurerm_public_ip.pip[0].name : ""
}

output "virtual_network_gateway_bgp_peering_addresses" {
  description = "A list of peering_addresses for the BGP peer of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.vnet_gw.bgp_settings.0.peering_addresses
}

output "virtual_network_gateway_bgp_settings" {
  description = "A block of bgp_settings of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.vnet_gw.bgp_settings
}

output "virtual_network_gateway_default_addresses" {
  description = "A list of peering address assigned to the BGP peer of the Virtual Network Gateway."
  value       = [for address in azurerm_virtual_network_gateway.vnet_gw.bgp_settings.0.peering_addresses : address.default_addresses]
}

output "virtual_network_gateway_id" {
  description = "The ID of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.vnet_gw.id
}

output "virtual_network_gateway_tunnel_ip_addresses" {
  description = "A list of tunnel IP addresses assigned to the BGP peer of the Virtual Network Gateway."
  value       = [for address in azurerm_virtual_network_gateway.vnet_gw.bgp_settings.0.peering_addresses : address.tunnel_ip_addresses]
}
