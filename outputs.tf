output "unik_node" {
  description = "Login to your machine"
  value       = "\n\tssh -i ${local_file.unik_private_key_pem.filename} root@${metal_device.unik.network.0.address}"
}
