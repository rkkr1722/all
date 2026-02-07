#################
# Resource Group
#################
resource "azurerm_resource_group" "pol" {
  name     = "rg-poland"
  location = var.regions.poland
}

############################
# Virtual Network And Subnet
############################
resource "azurerm_virtual_network" "pol" {
  name                = "vnet-poland"
  location            = azurerm_resource_group.pol.location
  resource_group_name = azurerm_resource_group.pol.name
  address_space       = var.vnet_address_space_pol
}

resource "azurerm_subnet" "pol" {
  name                 = "subnet-01"
  resource_group_name  = azurerm_resource_group.pol.name
  virtual_network_name = azurerm_virtual_network.pol.name
  address_prefixes     = var.subnet_address_space_pol
}

##############
# Public IPs
##############
# pol India VM Public IP
resource "azurerm_public_ip" "pol_pip" {
  name                = "pip-poland"
  location            = azurerm_resource_group.pol.location
  resource_group_name = azurerm_resource_group.pol.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

###############
# NIC - poland
###############
resource "azurerm_network_interface" "pol_nic" {
  name                = "nic-poland"
  location            = azurerm_resource_group.pol.location
  resource_group_name = azurerm_resource_group.pol.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.pol.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pol_pip.id
  }
}

#####################
# VM - poland
#####################
resource "azurerm_linux_virtual_machine" "pol_vm" {
  name                = "vm-poland"
  location            = azurerm_resource_group.pol.location
  resource_group_name = azurerm_resource_group.pol.name
  size                = var.vm_size
  network_interface_ids = [azurerm_network_interface.pol_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  lifecycle {
  prevent_destroy = false
  }

  source_image_reference {
  publisher = "Debian"
  offer     = "debian-13"
  sku       = "13"
  version   = "latest"
  }
}
