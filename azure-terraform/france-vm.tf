
resource "azurerm_resource_group" "france" {
  name     = "rg-francecentral"
  location = "France Central"
}

############################
# Virtual Network And Subnet
############################

resource "azurerm_virtual_network" "france" {
  name                = "vnet-francecentral"
  location            = azurerm_resource_group.france.location
  resource_group_name = azurerm_resource_group.france.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "france" {
  name                 = "subnet-01"
  resource_group_name  = azurerm_resource_group.france.name
  virtual_network_name = azurerm_virtual_network.france.name
  address_prefixes     = var.subnet_address_space
}

################
# NSG 22 and 80
################
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-ssh-http"
  location            = azurerm_resource_group.france.location
  resource_group_name = azurerm_resource_group.france.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#######################
# NIC - France Central
#######################
# France Central (ONLY ONE IP)
resource "azurerm_public_ip" "france_pip" {
  name                = "pip-francecentral"
  location            = azurerm_resource_group.france.location
  resource_group_name = azurerm_resource_group.france.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "france_nic" {
  count               = 2
  name                = "nic-france-${count.index}"
  location            = azurerm_resource_group.france.location
  resource_group_name = azurerm_resource_group.france.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.france.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = count.index == 0 ? azurerm_public_ip.france_pip.id : null
  }
}

######################
# VM - France Central
######################
resource "azurerm_linux_virtual_machine" "france_vm" {
  count               = 2
  name                = "vm-france-${count.index}"
  location            = azurerm_resource_group.france.location
  resource_group_name = azurerm_resource_group.france.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.france_nic[count.index].id]

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
