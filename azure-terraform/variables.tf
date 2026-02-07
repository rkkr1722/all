variable "admin_username" {
  default = "anon"
}

variable "admin_password" {
  default = "S3cReT0212"
}

variable "vm_size" {
  default = "Standard_B1ls"
}

variable "fr_vm_count" {
  default = 2
}
variable "vnet_address_space_pol" {
  default = ["10.10.0.0/16"]
}

variable "subnet_address_space_pol" {
  default = ["10.10.1.0/24"]
}

variable "vnet_address_space_fr" {
  default = ["10.15.0.0/16"]
}

variable "subnet_address_space_fr" {
  default = ["10.15.1.0/24"]
}

variable "vnet_address_space_in" {
  default = ["10.20.0.0/16"]
}

variable "subnet_address_space_in" {
  default = ["10.20.1.0/24"]
}

variable "regions" {
  type = map(string)
  default = {
    southindia    = "South India"
    france = "France Central"
    poland = "Poland Central"
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "South India"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-vm-southindia"
}

#################################################
#variable "vm_count_per_region" {
  #type = map(number)
  #default = {
    #southindia    = 1
    #francecentral = 3
  #}
#}