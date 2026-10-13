variable "image" {
  description = "bootstrap image used by 'nixos-anywhere' to kexec into nixos installer"
  type        = string
  default     = "images:debian/13/cloud"
}

variable "root_ssh_authkeys" {
  description = "list of ssh auth keys for 'root' user"
  type        = list(string)
}
