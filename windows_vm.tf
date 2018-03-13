resource "azurerm_storage_account" "diagnostics" {
  name                      = "${var.vm_name_prefix}"
  resource_group_name       = "${var.resource_group_name}"
  location                  = "${var.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true

  tags = "${var.tags}"
}

data "template_file" "auto_logon" {
  template = "${file("${path.module}/tpl.auto_logon.xml")}"

  vars {
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }
}

resource "azurerm_virtual_machine" "windows_vm" {
  count               = "${var.vm_count}"
  name                = "${var.vm_name_prefix}-${format("%02d", count.index)}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  vm_size             = "${var.vm_size}"

  network_interface_ids = ["${element(var.network_interface_ids, count.index)}"]
  availability_set_id   = "${var.availability_set_id}"

  delete_os_disk_on_termination    = "${var.vm_immutable_os_disk}"
  delete_data_disks_on_termination = "${var.vm_immutable_data_disk}"

  storage_image_reference = ["${var.vm_image}"]

  storage_os_disk {
    name              = "${var.vm_name_prefix}-${format("%02d", count.index)}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.vm_os_disk_type}"
  }

  storage_data_disk {
    name              = "${var.vm_name_prefix}-${format("%02d", count.index)}-data"
    lun               = 0
    caching           = "ReadWrite"
    create_option     = "Empty"
    managed_disk_type = "${var.vm_data_disk_type}"
    disk_size_gb      = "${var.vm_data_disk_size}"
  }

  os_profile {
    computer_name  = "${var.vm_name_prefix}-${format("%02d", count.index)}"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
    custom_data    = "${var.vm_init_script}"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "${data.template_file.auto_logon.rendered}"
    }

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = "${file("${path.module}/tpl.first_logon_commands.xml")}"
    }
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.diagnostics.primary_blob_endpoint}"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine_extension" "windows_vm" {
  count                = "${var.vm_count}"
  name                 = "${var.vm_name_prefix}-${format("%02d", count.index)}"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_machine_name = "${element(azurerm_virtual_machine.windows_vm.*.name, count.index)}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = <<-SETTINGS
    {
        "Name": "${var.domain_name}",
        "OUPath": "${var.OU_path}",
        "User": "${var.OU_User_Domain}\\${var.OU_User}",
        "Restart": "true",
        "Options": "3"
    }
  SETTINGS

  protected_settings = <<-PROTECTED
  {
        "Password": "${var.OU_user_pass}"
  }
  PROTECTED

  tags = "${var.tags}"
}
