# General
variable "resource_group_name" {
  type        = "string"
  description = "Name of the resource group"
}
variable "location" {
  type        = "string"
  description = "Azure region all the resources will be deployed to"
}
variable "tags" {
  type        = "map"
  description = <<-HEREDOC
  Everything should be tagged, for guidance see:-
  https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-subscription-governance#resource-tags
  HEREDOC
}

# Networking
variable "subnet_id" {
  type        = "string"
  description = "ID of the subnet to join"
}
variable "network_interface_ids" {
  type        = "list"
  description = "List of network interface ids"
}
variable "availability_set_id" {
  type        = "string"
  default     = ""
  description = "ID of the Availability Set to join"
}

# VMs
variable "vm_name_prefix" {
  type        = "string"
  description = "Prefix to the name of the VMs to create in the scale set"
}
variable "vm_count" {
  type        = "string"
  description = "How many VMs would you like?"
}
variable "vm_size" {
  type        = "string"
  description = <<-HEREDOC
  Select the size of the VMs to create:-
  https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes
  HEREDOC
}
variable "vm_image" {
  type        = "map"
  description = <<-HEREDOC
    Can either be a reference to an Azure Marketplace image:-
    https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage
    or PowerShell:-
      $loc = [your-azure-region-here]
      $pub = 'MicrosoftWindowsServer'
      $off = 'WindowsServer'
      Get-AzureRMVMImageSku -Location $loc -Publisher $pub -Offer $off
      {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2016-Datacenter-smalldisk"
        version   = "latest"
      }
    Or a custom image you have stored in Azure:-
      {
        id = "${azurerm_image.test.id}"
      }
  HEREDOC
}
variable "vm_immutable_os_disk" {
  type        = "string"
  default     = true
  description = "Delete managed OS disk when you delete the VM"
}
variable "vm_immutable_data_disk" {
  type        = "string"
  default     = true
  description = "Delete managed data disk when you delete the VM"
}
variable "vm_os_disk_type" {
  type        = "string"
  default     = "Premium_LRS"
  description = "Premium_LRS is recommended"
}
variable "vm_data_disk_type" {
  type        = "string"
  default     = "Premium_LRS"
  description = "Premium_LRS or Standard_LRS"
}
variable "vm_data_disk_size" {
  type        = "string"
  default     = 10
  description = "Size of the data disk in GB"
}
variable "vm_admin_username" {
  type        = "string"
  description = "Username for the local administrator account"
}
variable "vm_admin_password" {
  type        = "string"
  description = "Password for the local administrator account"
}
variable "vm_init_script" {
  type        = "string"
  description = "PowerShell script to initialise the VM"
}
