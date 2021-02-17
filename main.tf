resource "random_id" "cloud" {
  byte_length = 8
}

provider "metal" {
  auth_token = var.auth_token
}

resource "metal_project" "project" {
  name = format("unik-%s", random_id.cloud.b64_url)
}

locals {
  ssh_key_name = format("metal-key-unik-%s", random_id.cloud.b64_url)
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "metal_ssh_key" "ssh_pub_key" {
  name       = random_id.cloud.b64_url
  public_key = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
}

resource "local_file" "unik_private_key_pem" {
  content         = chomp(tls_private_key.ssh_key_pair.private_key_pem)
  filename        = pathexpand(format("%s", local.ssh_key_name))
  file_permission = "0600"
}

resource "local_file" "unik_public_key" {
  content         = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
  filename        = pathexpand(format("%s.pub", local.ssh_key_name))
  file_permission = "0600"
}

resource "metal_device" "unik" {
  hostname         = "unik-qemu-node"
  plan             = var.metal_plan
  facilities       = ["ewr1"]
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = metal_project.project.id

  connection {
    host        = self.access_public_ipv4
    type        = "ssh"
    user        = "root"
    private_key = local_file.unik_private_key_pem.content
  }

  user_data = file("${path.module}/userdata.tpl")
}

resource "null_resource" "distribute-setup" {
  connection {
    host        = metal_device.unik.access_public_ipv4
    private_key = local_file.unik_private_key_pem.content
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup.sh"
    destination = "/root/setup.sh"
  }
}

resource "null_resource" "run-setup" {
  depends_on = [null_resource.distribute-setup]
  connection {
    host        = metal_device.unik.access_public_ipv4
    private_key = local_file.unik_private_key_pem.content
  }

  provisioner "remote-exec" {
    inline = [
      "bash /root/setup.sh",
    ]
  }
}
