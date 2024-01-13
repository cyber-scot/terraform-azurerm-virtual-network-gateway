module "rg" {
  source = "cyber-scot/rg/azurerm"

  name     = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags
}

data "azurerm_subscription" "current" {}

module "network" {
  source = "cyber-scot/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name          = "vnet-${var.short}-${var.loc}-${var.env}-01"
  vnet_location      = module.rg.rg_location
  vnet_address_space = ["10.0.0.0/16"]

  subnets = {
    "GatewaySubnet" = {
      address_prefixes = ["10.0.0.0/27"]
    }
  }
}

module "vpn" {
  source = "../../"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  name                   = "vpn-${var.short}-${var.loc}-${var.env}-01"
  create_public_ip       = true
  type                   = "Vpn"
  vpn_type               = "RouteBased"
  sku                    = "VpnGw1"
  active_active          = false
  enable_bgp             = false
  generation             = "Generation1"
  dns_forwarding_enabled = false # Only supports for ExpressRoute

  ip_configuration = [
    {
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = module.network.subnets_ids["GatewaySubnet"]
    }
  ]
}
