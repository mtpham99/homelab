# --- vlans ---

variable "vlans" {
  description = "vlan definitions"
  type = map(object({
    comment = optional(string)
    id      = number
    svi     = optional(string)
  }))
}


# --- interfaces ---

variable "interfaces" {
  description = "interface definitions"
  type = map(object({
    comment  = optional(string)
    disabled = optional(bool, false)
    bridged  = optional(bool, true)
    tagged   = optional(list(string), [])
    untagged = optional(string)

    mtu   = optional(number)
    l2mtu = optional(number)
  }))
}


# --- bonds ---

variable "bonds" {
  description = "bond definitions"
  type = map(object({
    comment  = optional(string)
    disabled = optional(bool, false)
    bridged  = optional(bool, true)
    tagged   = optional(list(string), [])
    untagged = optional(string)

    slaves = list(string)
    mode   = string

    mtu                  = optional(number)
    transmit_hash_policy = optional(string)
    lacp_rate            = optional(string)
  }))
  default = {}
}
