# Déploiement d'une infrastructure de VMs sur Azure avec Terraform

Ce projet déploie une infrastructure complète sur Microsoft Azure en utilisant Terraform. Il a pour but de démontrer les compétences en Infrastructure as Code (IaC) pour automatiser la création de ressources cloud.

## Architecture

L'infrastructure créée par ce code est composée des éléments suivants :
- **Groupe de Ressources** : Un conteneur logique pour toutes les ressources du projet.
- **Réseau Virtuel (VNet)** : Un réseau isolé pour l'infrastructure.
- **Sous-réseau (Subnet)** : Une subdivision du VNet pour y placer les machines virtuelles.
- **Groupe de Sécurité Réseau (NSG)** : Des règles de pare-feu pour autoriser le trafic SSH (port 22) vers nos machines.
- **Machines Virtuelles (VMs)** : Plusieurs machines virtuelles Linux (Ubuntu) déployées sur la base de la configuration dans `terraform.tfvars`.

## Prérequis

Avant de commencer, assurez-vous d'avoir installé les outils suivants :
- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Git](https://git-scm.com/downloads)

Vous devez également être connecté à votre compte Azure via l'Azure CLI :
```bash
az login
az account set --subscription "VOTRE_ID_DE_SOUSCRIPTION"
```

## Déploiement

1. **Clonez ce dépôt :**
   ```bash
   git clone [https://github.com/VOTRE_PSEUDO/NOM_DU_PROJET.git](https://github.com/VOTRE_PSEUDO/NOM_DU_PROJET.git)
   cd NOM_DU_PROJET
   ```

2. **Configurez vos variables :**
   Copiez le fichier d'exemple pour créer votre propre fichier de variables.
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   **Modifiez le fichier `terraform.tfvars`** pour y mettre vos propres valeurs, notamment un mot de passe sécurisé pour l'administrateur des VMs. **Ce fichier est ignoré par Git et ne sera jamais publié.**

3. **Initialisez Terraform :**
   Cette commande télécharge les fournisseurs nécessaires.
   ```bash
   terraform init
   ```

4. **Planifiez le déploiement :**
   Cette commande vous montre ce que Terraform va créer, modifier ou supprimer.
   ```bash
   terraform plan
   ```

5. **Appliquez la configuration :**
   Lancez la création de l'infrastructure. Tapez `yes` lorsque demandé.
   ```bash
   terraform apply
   ```

## Captures d'écran

*(Vous pouvez ajouter ici des captures d'écran du déploiement réussi ou des ressources dans le portail Azure)*

![Exemple de sortie Terraform](screenshots/exemple.png)

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](./LICENSE) pour plus de détails.