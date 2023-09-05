resource "openstack_compute_instance_v2" "storage_server_1" {
  name        = "storage_server_1"
  flavor_name = "b2.c1r2"
  image_name  = "ubuntu-22-04"
  key_pair    = "master_key"

  network {
    name = "default"
  }

  metadata = {
    puppet_role = "storage"
  }

  block_device {
    uuid                  = "aac74808-9dba-4f49-a530-70a23b4163f3"
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 20
    boot_index            = 0
    delete_on_termination = true
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network[0].access_ip_v4
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install wget -y",
      "wget https://apt.puppetlabs.com/puppet6-release-focal.deb",
      "sudo dpkg -i puppet6-release-focal.deb",
      "sudo apt-get update",
      "sudo apt-get -y install puppet-agent",
      "sudo systemctl start puppet",
      "sudo systemctl enable puppet",
      "sudo puppet agent --test",  # Removed the 'sudo ssh puppetmaster' line
    ]
  }
}
