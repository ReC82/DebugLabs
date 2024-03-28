resource "null_resource" "output_private_ips" {
  # This resource is just used as a placeholder to trigger the local-exec provisioner
  provisioner "local-exec" {
    command     = <<EOT
      $privateIps = "${join(",", azurerm_linux_virtual_machine.nodes.*.private_ip_address)}"
      $nodeNames = "${join(",", azurerm_linux_virtual_machine.nodes.*.name)}"
      $nodeNames | Out-File "raw_node_names.txt"
      $list_ip_file="private_nodes.txt"
      Remove-Item -Path $list_ip_file -ErrorAction SilentlyContinue
      
      "[nodes]" | Out-file $list_ip_file -Encoding utf8

      # Split the IP addresses using the comma separator and add each IP address under the "nodes" key with proper indentation
      $privateIps.Split(",") | ForEach-Object {
          $_ | Out-file -Append $list_ip_file -Encoding utf8
      }
      EOT
      interpreter = ["PowerShell", "-Command"]
  }
}

resource "null_resource" "cp_iplist" {
  provisioner "file" {
    source      = "private_nodes.txt"
    destination = "/home/rooty/private_nodes.txt"
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.pubip_controller.ip_address
      user        = "rooty"
      private_key = tls_private_key.ssh_key_linux_openssh.private_key_openssh
    }
  }
  depends_on = [null_resource.output_private_ips]
}
# terraform apply -replace null_resource.output_private_ips -replace null_resource.cp_iplist
/* This will stuck the ansible installation
resource "null_resource" "copy_node_list" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.pubip_controller.ip_address
      user        = "rooty"
      private_key = tls_private_key.ssh_key_linux_openssh.private_key_pem
    }

    inline = [
      "sudo mkdir -p /etc/ansible",
      "sudo sh -c 'cat /home/rooty/private_nodes.txt >> /etc/ansible/hosts'"
    ]
  }

  depends_on = [null_resource.cp_iplist]
}*/


output "private_key" {
  value     = tls_private_key.ssh_key_linux_openssh.private_key_pem
  sensitive = true
}

output "controller_ip" {
  value = azurerm_public_ip.pubip_controller.ip_address
}

output "private_ip_addresses" {
  value = {
    for idx, nic in azurerm_network_interface.nic_ansible_node : idx => nic.ip_configuration[0].private_ip_address
  }
}
