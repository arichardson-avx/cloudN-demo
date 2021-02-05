resource "random_integer" "priority" {
  for_each = var.ssh_addresses

  min = 500
  max = 4095
}

resource "azurerm_resource_group" "security_groups" {
  name     = "${replace(var.region, " ", "-")}-security-groups"
  location = var.region
}

resource "azurerm_network_security_group" "public" {
  name                = "All-RFC1918-and-ssh"
  resource_group_name = azurerm_resource_group.security_groups.name
  location            = var.region
}

resource "azurerm_network_security_rule" "egress_all_public" {
  name                        = "Any-from-0.0.0.0"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.security_groups.name
  network_security_group_name = azurerm_network_security_group.public.name
}

resource "azurerm_network_security_rule" "ingress_rfc1918_public" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  name                        = "Any-from-${split("/", each.key)[0]}"
  priority                    = split(".", each.key)[1] + 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = each.value
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.security_groups.name
  network_security_group_name = azurerm_network_security_group.public.name
}

resource "azurerm_network_security_rule" "ssh_from_internet" {
  for_each = var.ssh_addresses

  name                        = "ssh-from-${split("/", each.key)[0]}"
  priority                    = random_integer.priority[each.value].result
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = each.value
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.security_groups.name
  network_security_group_name = azurerm_network_security_group.public.name
}

resource "azurerm_network_security_group" "private" {
  name                = "All-RFC1918"
  resource_group_name = azurerm_resource_group.security_groups.name
  location            = var.region
}

resource "azurerm_network_security_rule" "egress_all_private" {
  name                        = "Any-to-0.0.0.0"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.security_groups.name
  network_security_group_name = azurerm_network_security_group.private.name
}

resource "azurerm_network_security_rule" "ingress_rfc1918_private" {
  for_each = toset(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])

  name                        = "Any-from-${split("/", each.key)[0]}"
  priority                    = split(".", each.key)[1] + 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = each.value
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.security_groups.name
  network_security_group_name = azurerm_network_security_group.private.name
}
