terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  cloud = "openstack" # defined in ~/.config/openstack/clouds.yaml
}

# Define your OpenStack provider configuration here

# Create Storage Server 1
resource "openstack_compute_instance_v2" "storage_server_1" {
  name        = "storage-server-1"
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
      "sudo puppet agent --test",
    ]
  }
}

# Create Development Servers (Server 2 and Server 3)
resource "openstack_compute_instance_v2" "development_server" {
  count       = 2
  name        = "development-server-${count.index + 2}"
  flavor_name = "b2.c1r2"
  image_name  = "ubuntu-22-04"
  key_pair    = "master_key"

  network {
    name = "default"
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
      "sudo apt-get install emacs jed git -y",
      "sudo groupadd developers",          # Create the developers group
      "sudo useradd -m -s /bin/bash bob",  # Create user bob
      "sudo useradd -m -s /bin/bash janet",# Create user janet
      "sudo useradd -m -s /bin/bash alice",# Create user alice
      "sudo useradd -m -s /bin/bash tim",  # Create user tim
      "sudo usermod -aG developers tim",   # Add users to the developers group
      "sudo usermod -aG developers janet",
      "echo 'bob ALL=(ALL:ALL) ALL' | sudo tee -a /etc/sudoers.d/99_bob",  # Configure sudo access
      "echo 'janet ALL=(ALL:ALL) ALL' | sudo tee -a /etc/sudoers.d/99_janet",
      "echo 'alice ALL=(ALL:ALL) ALL' | sudo tee -a /etc/sudoers.d/99_alice",
      "echo 'tim ALL=(ALL:ALL) ALL' | sudo tee -a /etc/sudoers.d/99_tim",
    ]
  }
}

# Create Compile Servers (Server 4 and Server 5)
resource "openstack_compute_instance_v2" "compile_server" {
  count       = 2
  name        = "compile-server-${count.index + 4}"
  flavor_name = "b2.c1r2"
  image_name  = "ubuntu-22-04"
  key_pair    = "master_key"

  network {
    name = "default"
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
      "sudo apt-get install gcc make binutils -y",
    ]
  }
}

# Create Docker Testing Server (Server 6)
resource "openstack_compute_instance_v2" "docker_server" {
  name        = "docker-server-6"
  flavor_name = "b2.c1r2"
  image_name  = "ubuntu-22-04"
  key_pair    = "master_key"

  network {
    name = "default"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network[0].access_ip_v4
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
    ]
  }
}
