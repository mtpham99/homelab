variable "routeros_hosturl" {
  description = "rest api url"
  type        = string
}

variable "routeros_insecure" {
  description = "skip tls verification"
  type        = bool
  default     = true
}

variable "routeros_ca_certificate" {
  description = "path to ca certificate for tls verification"
  type        = string
  default     = ""
}
