resource "null_resource" "cp_playbooks" {
  provisioner "file" {
    source      = "./ansible"
    destination = "/home/rooty/ansible_files"

    connection {
      type        = "ssh"
      host        = azurerm_public_ip.pubip_controller.ip_address
      user        = "rooty"
      private_key = tls_private_key.ssh_key_linux_openssh.private_key_openssh
      agent       = false # Optional: disable SSH agent forwarding
    }
  }
}