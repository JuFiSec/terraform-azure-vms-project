# Fichier: variables.tf

# --- Variables pour la localisation et les noms ---
variable "location" {
  description = "Région Azure où déployer les ressources" # 
  type        = string                                    # 
  default     = "West Europe"                            # 
}

variable "resource_group_name" {
  description = "Nom du groupe de ressources" # 
  type        = string                        # 
  default     = "rg-multiples-vms"            # 
}

variable "vnet_name" {
  description = "Nom du réseau virtuel" # 
  type        = string                  # 
  default     = "vnet-vms"              # 
}

variable "subnet_name" {
  description = "Nom du sous-réseau" # 
  type        = string               # 
  default     = "subnet-vms"         # 
}

# --- Variables pour les plages d'adresses IP ---
variable "address_space_vnet" {
  description = "Plage d'adresses IP pour le réseau virtuel" # 
  type        = list(string)                                 # 
  default     = ["10.0.0.0/16"]                              # 
}

variable "address_prefix_subnet" {
  description = "Plage d'adresses IP pour le sous-réseau" # 
  type        = string                                    # 
  default     = "10.0.1.0/24"                             # 
}

# --- Variables pour les machines virtuelles avec count ---
variable "vm_count" {
  description = "Nombre de VMs à créer avec count" # 
  type        = number                             # 
  default     = 3                                  # 
}

variable "vm_name_prefix" {
  description = "Préfixe pour les noms des VMs" # 
  type        = string                          # 
  default     = "vm-linux"                      # 
}

variable "vm_size" {
  description = "Taille des machines virtuelles" # 
  type        = string                           # 
  default     = "Standard_DS1_v2"                   # 
}

variable "admin_username" {
  description = "Nom d'utilisateur administrateur pour les VMs" # 
  type        = string                                          # 
  default     = "azureuser"                                     # 
}

variable "admin_password" {
  description = "Mot de passe administrateur pour les VMs" # 
  type        = string                                     # 
  sensitive   = true                                       # 
}

# --- Variables pour les machines virtuelles avec for_each ---
variable "vms_config" {
  description = "Configuration des VMs avec for_each" # 
  type = map(object({
    vm_size = string # 
    zone    = string # 
  }))                # 
  default = {
    "web" = {
      vm_size = "Standard_DS1_v2" # 
      zone    = "1"               # 
    },
    "app" = {
      vm_size = "Standard_DS1_v2" # 
      zone    = "2"               # 
    },
    "db" = {
      vm_size = "Standard_DS1_v2" # 
      zone    = "3"               # 
    }
  } # 
}

# --- Variable pour les tags ---
variable "tags" {
  description = "Tags à appliquer aux ressources" # 
  type        = map(string)                       # 
  default = {
    Environment = "Development"  # 
    Project     = "TD-Terraform" # 
    Module      = "3"            # 
  }                              # 
}