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
  }))
}