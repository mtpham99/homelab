# --- wireguard server ---

variable "name" {
  description = "Interface name for wireguard server"
  type        = string
}

variable "port" {
  description = "wireguard udp port"
  type        = number
  default     = 51820

  validation {
    condition     = 0 < var.port && var.port <= 65535
    error_message = "port number must be in the range (0, 65535]"
  }
}

variable "subnet" {
  description = "tunnel subnet in cidr notation"
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet, 0))
    error_message = "invalid cidr string"
  }
}

variable "endpoint" {
  description = "wan endpoint for wireguard server peers will connect to"
  type        = string
  sensitive   = true
}

variable "private_key" {
  description = "server's private key"
  type        = string
  default     = null
  sensitive   = true
}


# --- wireguard peers ---

variable "peers" {
  description = "wireguard peer definitions"

  type = map(object({
    public_key    = string
    preshared_key = optional(string)
    peer_address  = string
    peer_dns      = optional(string)
    # TODO: pr #987: https://github.com/terraform-routeros/terraform-provider-routeros/pull/987
    # peer_allowed_address = optional(list(string))
  }))

  default = {}

  validation {
    condition = alltrue([
      for peer_k, peer_v in var.peers : can(cidrhost("${peer_v.peer_address}/32", 0))
    ])
    error_message = "invalid ip address string"
  }

  validation {
    condition = alltrue([
      for peer_k, peer_v in var.peers : (
        peer_v.peer_dns == null ||
        can(cidrhost("${peer_v.peer_dns}/32", 0))
      )
    ])
    error_message = "invalid ip address string"
  }
}
