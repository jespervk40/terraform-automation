# Resource Group
resource "azurerm_resource_group" "MyResource" {
  name     = "MyResource"
  location = "West Europe"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.MyResource.location
  resource_group_name = azurerm_resource_group.MyResource.name
}
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.MyResource.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.0.0/24"]

}
resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet2"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.MyResource.location
  resource_group_name = azurerm_resource_group.MyResource.name
}


resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.MyResource.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Network Interface
resource "azurerm_network_interface" "NIC1" {
  name                = "MyNic1"
  location            = azurerm_resource_group.MyResource.location
  resource_group_name = azurerm_resource_group.MyResource.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network Interface for VM 2
resource "azurerm_network_interface" "NIC2" {
  name                = "MyNic2"
  location            = azurerm_resource_group.MyResource.location
  resource_group_name = azurerm_resource_group.MyResource.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Route table
resource "azurerm_route_table" "route_table" {
  name                = "acceptanceTestRouteTable1"
  location            = azurerm_resource_group.MyResource.location
  resource_group_name = azurerm_resource_group.MyResource.name
}

resource "azurerm_route" "route" {
  name                = "acceptanceTestRoute1"
  resource_group_name = azurerm_resource_group.MyResource.name
  route_table_name    = azurerm_route_table.route_table.name
  address_prefix      = "10.1.0.0/16"
  next_hop_type       = "VnetLocal"
}

#Public Ip
resource "azurerm_public_ip" "public_ip" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.MyResource.name
  location            = azurerm_resource_group.MyResource.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

#Public IP Prefix
resource "azurerm_public_ip_prefix" "public_ip_prifix" {
  name                = "acceptanceTestPublicIpPrefix1"
  location            = azurerm_resource_group.MyResource.location
  resource_group_name = azurerm_resource_group.MyResource.name

  prefix_length = 31

  tags = {
    environment = "Production"
  }
}

# Netwoek Peering
resource "azurerm_virtual_network" "vnet-1" {
  name                = "peternetwork1"
  resource_group_name = azurerm_resource_group.MyResource.name
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.MyResource.location
}

resource "azurerm_virtual_network" "vnet-2" {
  name                = "peternetwork2"
  resource_group_name = azurerm_resource_group.MyResource.name
  address_space       = ["10.0.2.0/24"]
  location            = azurerm_resource_group.MyResource.location
}

resource "azurerm_virtual_network_peering" "vnetpeering-1" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.MyResource.name
  virtual_network_name      = azurerm_virtual_network.vnet-1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-2.id
}

resource "azurerm_virtual_network_peering" "vnetpeering-2" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.MyResource.name
  virtual_network_name      = azurerm_virtual_network.vnet-2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-1.id
}


# Security Rule
resource "azurerm_network_security_group" "NSG" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.MyResource.location
  resource_group_name = azurerm_resource_group.MyResource.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}



# Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "test-vm"
  resource_group_name = azurerm_resource_group.MyResource.name
  location            = azurerm_resource_group.MyResource.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [azurerm_network_interface.NIC1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "vm2" {
  name                = "test-vm2"
  resource_group_name = azurerm_resource_group.MyResource.name
  location            = azurerm_resource_group.MyResource.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.NIC2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

#NOTE
#kill terraform process-kill -9 
#Find the terraform Process ID using the command ps aux | grep terraform
#Kill the process using - kill -9 <process_id>