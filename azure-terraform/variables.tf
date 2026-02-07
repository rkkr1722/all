variable "admin_username" {
  default = "anon"
}

variable "vm_size" {
  default = "Standard_B1ls"
}

variable "vnet_address_space" {
  default = ["10.10.0.0/16"]
}

variable "subnet_address_space" {
  default = ["10.10.1.0/24"]
}

variable "regions" {
  type = map(string)
  default = {
    southindia    = "South India"
    francecentral = "France Central"
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