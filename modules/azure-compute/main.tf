# -----------------------------------------------------------------------------
# Network Interfaces
# -----------------------------------------------------------------------------

resource "azurerm_network_interface" "this" {
  count = var.vm_count

  name                = "${var.name_prefix}-nic-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.extra_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# -----------------------------------------------------------------------------
# SSH Key
# -----------------------------------------------------------------------------

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# -----------------------------------------------------------------------------
# Linux Virtual Machines
# -----------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "this" {
  count = var.vm_count

  name                            = "${var.name_prefix}-vm-${count.index + 1}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.this[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    name                 = "${var.name_prefix}-osdisk-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = merge(var.extra_tags, {
    Name = "${var.name_prefix}-vm-${count.index + 1}"
  })
}
