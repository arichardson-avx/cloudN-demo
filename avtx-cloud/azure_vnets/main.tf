resource "aviatrix_vpc" "azure_vnet" {
  for_each = var.vnet_data

  cloud_type           = 8
  account_name         = var.account_name
  region               = var.region
  name                 = each.value.name
  cidr                 = each.value.cidr
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
}

resource "aviatrix_spoke_gateway" "avtx_spoke_vnet" {
  for_each = var.native_peering ? {} : var.vnet_data

  cloud_type         = 8
  account_name       = var.account_name
  gw_name            = "${lower(each.value.name)}-gw"
  vpc_id             = aviatrix_vpc.azure_vnet[each.key].vpc_id
  vpc_reg            = var.region
  insane_mode        = var.hpe
  ha_gw_size         = var.avtx_gw_ha ? var.avtx_gw_size : null
  gw_size            = var.avtx_gw_size
  subnet             = var.hpe ? cidrsubnet(aviatrix_vpc.azure_vnet[each.key].cidr, 2, 2) : aviatrix_vpc.azure_vnet[each.key].subnets[0].cidr
  ha_subnet          = var.avtx_gw_ha ? (var.hpe ? cidrsubnet(aviatrix_vpc.azure_vnet[each.key].cidr, 2, 3) : aviatrix_vpc.azure_vnet[each.key].subnets[2].cidr) : null
  transit_gw         = var.avx_transit_gw
  enable_active_mesh = true
}

resource "aviatrix_azure_spoke_native_peering" "spoke_native_peering" {
  for_each = var.native_peering ? var.vnet_data : {}
  #for_each = var.native_peering ? { for k, v in var.vnet_data : k => v if ! (contains(["vnet1"], k) && var.region == "West US") } : {}

  transit_gateway_name = var.avx_transit_gw
  spoke_account_name   = var.account_name
  spoke_region         = var.region
  spoke_vpc_id         = aviatrix_vpc.azure_vnet[each.key].vpc_id
}

resource "azurerm_resource_group" "compute" {
  for_each = var.create_public_vm || var.create_private_vm ? var.vnet_data : {}

  name     = "${each.value.name}-compute"
  location = var.region
}

resource "azurerm_public_ip" "azure_public" {
  for_each = var.create_public_vm ? var.vnet_data : {}

  name                = "${each.value.name}-public-ubuntu-eip"
  location            = var.region
  resource_group_name = azurerm_resource_group.compute[each.key].name
  allocation_method   = "Static"

  depends_on = [azurerm_resource_group.compute] # TF ocassionally throws an error on missing compute rg. Hope this will fix it 
}

resource "azurerm_network_interface" "azure_public" {
  for_each = var.create_public_vm ? var.vnet_data : {}

  name                = "${each.value.name}-public-ubuntu-nic1"
  location            = var.region
  resource_group_name = azurerm_resource_group.compute[each.key].name

  ip_configuration {
    name                          = "${each.value.name}-public-ubuntu-nic1"
    subnet_id                     = aviatrix_vpc.azure_vnet[each.key].public_subnets[1].subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure_public[each.key].id
  }

  depends_on = [azurerm_resource_group.compute] # TF ocassionally throws an error on missing compute rg. Hope this will fix it 
}

resource "azurerm_linux_virtual_machine" "public_vm" {
  for_each = var.create_public_vm ? var.vnet_data : {}

  name                            = "${each.value.name}-public-ubuntu-VM"
  location                        = var.region
  resource_group_name             = azurerm_resource_group.compute[each.key].name
  network_interface_ids           = [azurerm_network_interface.azure_public[each.key].id]
  size                            = var.instance_type
  admin_username                  = "ubuntu"
  admin_password                  = var.enable_public_vm_password ? var.ubuntu_password : null
  disable_password_authentication = var.enable_public_vm_password ? false : true
  custom_data                     = base64encode(var.custom_data)

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.key_name
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${each.value.name}-public-ubuntu-myosdisk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  depends_on = [azurerm_resource_group.compute] # TF ocassionally throws an error on missing compute rg. Hope this will fix it 
}

resource "azurerm_network_interface" "azure_private" {
  for_each = var.create_private_vm ? var.vnet_data : {}

  name                = "${each.value.name}-private-ubuntu-nic1"
  location            = var.region
  resource_group_name = azurerm_resource_group.compute[each.key].name

  ip_configuration {
    name                          = "${each.value.name}-private-ubuntu-nic1"
    subnet_id                     = aviatrix_vpc.azure_vnet[each.key].public_subnets[0].subnet_id # using public subnet to keep .10 address to be consistent with AWS setup
    private_ip_address_allocation = var.fixed_private_ip ? "Static" : "Dynamic"
    private_ip_address            = var.fixed_private_ip ? join("", [regex("([\\d+\\.]+)(\\.\\d+/\\d+)", aviatrix_vpc.azure_vnet[each.key].subnets[3].cidr)[0], ".", var.private_ip]) : null
  }

  depends_on = [azurerm_resource_group.compute] # TF ocassionally throws an error on missing compute rg. Hope this will fix it 
}

resource "azurerm_linux_virtual_machine" "private_vm" {
  for_each = var.create_private_vm ? var.vnet_data : {}

  name                            = "${each.value.name}-private-ubuntu-VM"
  location                        = var.region
  resource_group_name             = azurerm_resource_group.compute[each.key].name
  network_interface_ids           = [azurerm_network_interface.azure_private[each.key].id]
  size                            = var.instance_type
  admin_username                  = "ubuntu"
  admin_password                  = var.enable_private_vm_password ? var.ubuntu_password : null
  disable_password_authentication = var.enable_private_vm_password ? false : true
  custom_data                     = base64encode(var.custom_data)

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.key_name
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${each.value.name}-private-ubuntu-myosdisk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  depends_on = [azurerm_resource_group.compute] # TF ocassionally throws an error on missing compute rg. Hope this will fix it 
}

resource "azurerm_subnet_network_security_group_association" "public_0" {
  for_each = var.attach_rfc1918_sg ? var.vnet_data : {}

  subnet_id                 = aviatrix_vpc.azure_vnet[each.key].public_subnets[0].subnet_id
  network_security_group_id = var.public_sg_id
}

resource "azurerm_subnet_network_security_group_association" "public_1" {
  for_each = var.attach_rfc1918_sg ? var.vnet_data : {}

  subnet_id                 = aviatrix_vpc.azure_vnet[each.key].public_subnets[1].subnet_id
  network_security_group_id = var.public_sg_id
}

resource "azurerm_subnet_network_security_group_association" "public_2" {
  for_each = var.attach_rfc1918_sg ? var.vnet_data : {}

  subnet_id                 = aviatrix_vpc.azure_vnet[each.key].public_subnets[2].subnet_id
  network_security_group_id = var.public_sg_id
}

resource "azurerm_subnet_network_security_group_association" "private_1" {
  for_each = var.attach_rfc1918_sg ? var.vnet_data : {}

  subnet_id                 = aviatrix_vpc.azure_vnet[each.key].private_subnets[0].subnet_id
  network_security_group_id = var.private_sg_id
}

resource "azurerm_subnet_network_security_group_association" "private_2" {
  for_each = var.attach_rfc1918_sg ? var.vnet_data : {}

  subnet_id                 = aviatrix_vpc.azure_vnet[each.key].private_subnets[1].subnet_id
  network_security_group_id = var.private_sg_id
}

