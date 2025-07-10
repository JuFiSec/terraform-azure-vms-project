# Fichier: main.tf

# --- Configuration du provider Azure ---
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # 
      version = "~> 3.0"            # 
    }
  }
}

provider "azurerm" {
  features {} # 
}

# --- Création de l'infrastructure réseau de base ---

# 1. Groupe de ressources
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name # 
  location = var.location            # 
  tags     = var.tags                # 
}

# 2. Réseau Virtuel (VNet)
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name                        # 
  address_space       = var.address_space_vnet               #
  location            = azurerm_resource_group.main.location # 
  resource_group_name = azurerm_resource_group.main.name     #  
  tags                = var.tags                             # 
}

# 3. Sous-réseau (Subnet)
resource "azurerm_subnet" "main" {
  name                 = var.subnet_name                   # 
  resource_group_name  = azurerm_resource_group.main.name  # 
  virtual_network_name = azurerm_virtual_network.main.name # 
  address_prefixes     = [var.address_prefix_subnet]       # 
}

# 4. Groupe de Sécurité Réseau (NSG) pour autoriser SSH
resource "azurerm_network_security_group" "main" {
  name                = "nsg-vms"                            # 
  location            = azurerm_resource_group.main.location # 
  resource_group_name = azurerm_resource_group.main.name     # 


  security_rule {
    name                       = "SSH"     # 
    priority                   = 1001      # 
    direction                  = "Inbound" # 
    access                     = "Allow"   # 
    protocol                   = "Tcp"     # 
    source_port_range          = "*"       # 
    destination_port_range     = "22"      # 
    source_address_prefix      = "*"       # 
    destination_address_prefix = "*"       # 
  }

  tags = var.tags

}

# 5. Association du NSG au sous-réseau
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id                 # 
  network_security_group_id = azurerm_network_security_group.main.id # 
}


# ===============================================
# =====       DÉPLOIEMENT AVEC COUNT        =====
# ===============================================

# Création de multiples interfaces réseau (NIC) avec count
resource "azurerm_network_interface" "vm_count" {
  count               = var.vm_count                                                   # 
  name                = "nic-${var.vm_name_prefix}-${format("%02d", count.index + 1)}" # 
  location            = azurerm_resource_group.main.location                           # 
  resource_group_name = azurerm_resource_group.main.name                               # 

  ip_configuration {
    name                          = "internal"             # 
    subnet_id                     = azurerm_subnet.main.id # 
    private_ip_address_allocation = "Dynamic"              # 
  }

  tags = merge(var.tags, {
    VMIndex = count.index + 1 # 
  })                          # 
}

# Création de multiples VMs Linux avec count
resource "azurerm_linux_virtual_machine" "vm_count" {
  count                           = var.vm_count                                               # 
  name                            = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}" # 
  location                        = azurerm_resource_group.main.location                       # 
  resource_group_name             = azurerm_resource_group.main.name                           # 
  size                            = var.vm_size                                                # 
  admin_username                  = var.admin_username                                         # 
  disable_password_authentication = false                                                      # 

  network_interface_ids = [azurerm_network_interface.vm_count[count.index].id, ] # 

  admin_password = var.admin_password #

  os_disk {
    caching              = "ReadWrite"   # 
    storage_account_type = "Premium_LRS" # 
  }

  source_image_reference {
    publisher = "Canonical"                    # 
    offer     = "0001-com-ubuntu-server-jammy" # 
    sku       = "22_04-lts-gen2"               # 
    version   = "latest"                       # 
  }

  tags = merge(var.tags, {
    VMIndex = count.index + 1, # 
    Type    = "Count-Based"    # 
  })                           # 
}


# ===============================================
# =====     DÉPLOIEMENT AVEC FOR_EACH       =====
# ===============================================

# Création de multiples interfaces réseau (NIC) avec for_each
resource "azurerm_network_interface" "vm_foreach" {
  for_each            = var.vms_config                       # 
  name                = "nic-vm-${each.key}"                 # 
  location            = azurerm_resource_group.main.location # 
  resource_group_name = azurerm_resource_group.main.name     # 

  ip_configuration {
    name                          = "internal"             # 
    subnet_id                     = azurerm_subnet.main.id # 
    private_ip_address_allocation = "Dynamic"              # 
  }

  tags = merge(var.tags, {
    VMRole = each.key,       # 
    Zone   = each.value.zone # 
  })                         # 
}

# Création de multiples VMs Linux avec for_each
resource "azurerm_linux_virtual_machine" "vm_foreach" {
  for_each                        = var.vms_config                       # 
  name                            = "vm-${each.key}"                     # 
  location                        = azurerm_resource_group.main.location # 
  resource_group_name             = azurerm_resource_group.main.name     # 
  size                            = each.value.vm_size                   # 
  admin_username                  = var.admin_username                   # 
  availability_set_id             = null                                 # 
  disable_password_authentication = false                                # 
  zone                            = each.value.zone                      # 

  network_interface_ids = [azurerm_network_interface.vm_foreach[each.key].id] # 
  admin_password        = var.admin_password                                  #

  os_disk {
    caching              = "ReadWrite"   # 
    storage_account_type = "Premium_LRS" # 
  }

  source_image_reference {
    publisher = "Canonical"                    # 
    offer     = "0001-com-ubuntu-server-jammy" # 
    sku       = "22_04-lts-gen2"               # 
    version   = "latest"                       # 
  }

  tags = merge(var.tags, {
    VMRole = each.key,        # 
    Type   = "ForEach-Based", # 
    Zone   = each.value.zone  # 
  })                          # 
}