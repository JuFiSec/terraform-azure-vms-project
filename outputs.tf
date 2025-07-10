# Fichier: outputs.tf

# --- Outputs pour l'infrastructure réseau ---
output "resource_group_id" {
  description = "ID du groupe de ressources"   # 
  value       = azurerm_resource_group.main.id # 
}

output "vnet_id" {
  description = "ID du réseau virtuel"          # 
  value       = azurerm_virtual_network.main.id # 
}


output "subnet_id" {
  description = "ID du sous-réseau"    # 
  value       = azurerm_subnet.main.id # 
}

# --- Outputs pour les VMs avec COUNT ---
output "vm_count_names" {
  description = "Noms des VMs créées avec count"               # 
  value       = azurerm_linux_virtual_machine.vm_count[*].name # 
}

output "vm_count_private_ips" {
  description = "Adresses IP privées des VMs créées avec count (REQUIS)"                     # 
  value       = azurerm_network_interface.vm_count[*].ip_configuration[0].private_ip_address # 
}

output "vm_count_ids" {
  description = "IDs des VMs créées avec count"
  value       = azurerm_linux_virtual_machine.vm_count[*].id #
}

# --- Outputs pour les VMs avec FOR_EACH ---
output "vm_foreach_details" {
  description = "Détails des VMs créées avec for_each" # 
  value = { for k, v in azurerm_linux_virtual_machine.vm_foreach : k => {
    name       = v.name                                                                         # 
    private_ip = azurerm_network_interface.vm_foreach[k].ip_configuration[0].private_ip_address # 
    size       = v.size                                                                         # 
    zone       = v.zone                                                                         # 
    }
  } # 
}

output "vm_foreach_private_ips" {
  description = "Adresses IP privées des VMs créées avec for_each"
  value = {
    for k, v in azurerm_network_interface.vm_foreach : k => v.ip_configuration[0].private_ip_address
  }
}


output "vm_foreach_names" {
  description = "Noms des VMs créées avec for_each"
  value = {
  for k, v in azurerm_linux_virtual_machine.vm_foreach : k => v.name }
}



# --- Output combiné et formatés---

output "all_vms_summary" {
  description = "Résumé de toutes les VMs déployées" # 
  value = {
    count_based = {
      count = length(azurerm_linux_virtual_machine.vm_count)                               # 
      names = azurerm_linux_virtual_machine.vm_count[*].name                               # 
      ips   = azurerm_network_interface.vm_count[*].ip_configuration[0].private_ip_address # 
    }                                                                                      # 
    foreach_based = {
      count = length(azurerm_linux_virtual_machine.vm_foreach) # 
      details = { for k, v in azurerm_linux_virtual_machine.vm_foreach : k => {
        name = v.name                                                                         # 
        ip   = azurerm_network_interface.vm_foreach[k].ip_configuration[0].private_ip_address # Note: Adjusted for modern provider versions
        size = v.size                                                                         # 
        }
      }                                                                                                           # 
    }                                                                                                             # 
    total_vms = length(azurerm_linux_virtual_machine.vm_count) + length(azurerm_linux_virtual_machine.vm_foreach) # 
  }
}

# --- Output pour les commandes de connexion SSH ---
output "ssh_connections" {
  description = "Commandes SSH pour se connecter aux VMs" # 
  value = {
    count_vms = [
      for i, vm in azurerm_linux_virtual_machine.vm_count :
      "ssh ${var.admin_username}@${azurerm_network_interface.vm_count[i].ip_configuration[0].private_ip_address}"
    ] # 
    foreach_vms = {
      for k, v in azurerm_linux_virtual_machine.vm_foreach :
      k => "ssh ${var.admin_username}@${azurerm_network_interface.vm_foreach[k].ip_configuration[0].private_ip_address}"
    } # 
  }
}