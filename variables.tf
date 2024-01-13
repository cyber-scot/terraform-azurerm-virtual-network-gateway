variable "active_active" {
  type        = bool
  description = "Whether to create an active-active gateway or not"
  default     = false
}

variable "bgp_route_translation_for_nat_enabled" {
  type        = bool
  description = "Whether BGP route transaltion for NAT is enabled on the VNet gateway"
  default     = false
}

variable "bgp_settings" {
  type = list(object({
    asn = optional(number)
    peering_address = optional(list(object({
      ip_configuration_name = optional(string)
      apipa_addresses       = optional(list(string))
    })))
    peer_weight = optional(number, 1)
  }))
  description = "The BGP settings block, if used"
  default     = []
}

variable "create_local_network_gateway" {
  type        = bool
  description = "Whether to create a local network gateway or not"
  default     = false
}

variable "create_public_ip" {
  type        = bool
  description = "Whether to create a public IP, or bring your own"
  default     = true
}

variable "custom_route" {
  type = list(object({
    address_prefixes = optional(list(string))
  }))
  description = "The custom route block, if used"
  default     = []
}

variable "default_local_network_gateway_id" {
  type        = string
  description = "The ID of the default local network gateway"
  default     = null
}

variable "dns_forwarding_enabled" {
  type        = bool
  description = "Whether DNS forwarding is enabled on the VNet gateway"
  default     = true
}

variable "edge_zone" {
  type        = string
  description = "The edge zone for the VNet to be deployed"
  default     = null
}

variable "enable_bgp" {
  type        = bool
  description = "Whether BGP should be enabled on the VNet gateway"
  default     = false
}

variable "generation" {
  type        = string
  description = "The generation of the VNet gateway, can either be Generation1 or Generation2 or None"
  default     = "Generation2"
}

variable "ip_configuration" {
  type = list(object({
    name                          = optional(string),
    public_ip_address_id          = optional(string)
    private_ip_address_allocation = optional(string, "Dynamic")
    subnet_id                     = optional(string)
  }))
  description = "The IP configuration block of the VNet gateway"
}

variable "ip_sec_replay_protection_enabled" {
  type        = bool
  description = "Whether IP Sec replay protection is enabled on the VNet gateway"
  default     = true
}

variable "local_network_gateway_address" {
  type        = string
  description = "The address of the local network gateway"
  default     = null
}

variable "local_network_gateway_address_space" {
  type        = list(string)
  description = "The address space of the local network gateway"
  default     = []
}

variable "local_network_gateway_bgp_settings" {
  type = list(object({
    asn                 = optional(number)
    bgp_peering_address = optional(string)
    peer_weight         = optional(number, 1)
  }))
  description = "The BGP settings block, if used"
  default     = []
}

variable "local_network_gateway_fqdn" {
  type        = string
  description = "The FQDN of the local network gateway"
  default     = null
}

variable "local_network_gateway_name" {
  type        = string
  description = "The name of the local network gateway"
  default     = null
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "name" {
  type        = string
  description = "The name of the VNet gateway"
}

variable "policy_group" {
  type = list(object({
    name = string
    policy_member = list(object({
      name  = string
      type  = string
      value = string
    }))
    is_default = optional(bool, false)
    priority   = optional(number, 0)
  }))
  description = "The policy group block, if used"
  default     = []
}

variable "private_ip_address_enabled" {
  type        = bool
  description = "Whether private IP address is enabled on the VNet gateway"
  default     = false
}

variable "public_ip_allocation_method" {
  type        = string
  description = "The allocation method of the public ip"
  default     = null
}

variable "public_ip_name" {
  type        = string
  description = "The name of the public IP"
  default     = null
}

variable "public_ip_sku" {
  type        = string
  description = "The sku of the public ip"
  default     = null
}

variable "remote_vnet_traffic_enabled" {
  type        = bool
  description = "Whether remote VNet traffic is enabled on the VNet gateway"
  default     = false
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
}

variable "sku" {
  type        = string
  description = "The SKU of the VNet gateway"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."
}

variable "type" {
  type        = string
  description = "The type of VPN gateway to create, either Vpn or ExpressRoute"
}

variable "virtual_wan_traffic_enabled" {
  type        = bool
  description = "Whether virtual wan traffic is enabled on the VNet gateway"
  default     = false
}

variable "vpn_client_configuration" {
  type = list(object({
    address_space  = string
    aad_tenant_url = optional(string)
    aad_audience   = optional(string)
    aad_issuer     = optional(string)

    ipsec_policy = optional(object({
      sa_data_size_in_kilobytes = number
      sa_lifetime_in_seconds    = number
      ipsec_encryption          = string
      ipsec_integrity           = string
      ike_encryption            = string
      ike_integrity             = string
      dh_group                  = string
      pfs_group                 = string
    }))
    radius_server = optional(list(object({
      address = string
      secret  = string
      score   = number
    })))
    radius_server_address = optional(string)
    radius_server_secret  = optional(string)
    root_certificate = optional(list(object({
      name             = string
      public_cert_data = string
    })))
    revoked_certificate = optional(list(object({
      name       = string
      thumbprint = string
    })))
    vpn_client_protocols = optional(list(string))
    vpn_auth_type        = optional(list(string))
    virtual_network_gateway_client_connection = optional(list(object({
      name              = string
      policy_group_name = list(string)
      address_prefixes  = list(string)
    })))
  }))
  description = "The VPN client configuration block, if used"
  default     = []
}

variable "vpn_type" {
  type        = string
  description = "The VPN type, can either be RouteBased or PolicyBased"
}
