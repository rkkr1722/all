#################
# Resource Group
#################
resource "azurerm_resource_group" "south" {
  name     = "rg-southindia"
  location = "South India"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

############################
# Virtual Network And Subnet
############################
resource "azurerm_virtual_network" "south" {
  name                = "vnet-southindia"
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "south" {
  name                 = "subnet-01"
  resource_group_name  = azurerm_resource_group.south.name
  virtual_network_name = azurerm_virtual_network.south.name
  address_prefixes     = var.subnet_address_space
}

##############
# Public IPs
##############
# South India VM Public IP
resource "azurerm_public_ip" "south_pip" {
  name                = "pip-southindia"
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

###############
# NIC - India
###############
resource "azurerm_network_interface" "south_nic" {
  name                = "nic-southindia"
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.south.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.south_pip.id
  }
}

#####################
# VM - South India
#####################
resource "azurerm_linux_virtual_machine" "south_vm" {
  name                = "vm-southindia"
  location            = azurerm_resource_group.south.location
  resource_group_name = azurerm_resource_group.south.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.south_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
