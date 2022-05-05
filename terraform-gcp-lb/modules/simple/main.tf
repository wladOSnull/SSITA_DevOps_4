resource "google_compute_instance" "default" {
  name         = "terragrunt"
  machine_type = "g1-small"
  zone         = "us-central1-a"

  tags = ["tag-terragrunt"]

  labels = {
    instance_type = "terragrunt"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20220204"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    foo = "bar"

    ssh-keys = "${var.ssh_admin}:${data.google_storage_bucket_object_content.key_server.content}"

    startup-script = <<SCRIPT
apt update
apt install -y apache2
echo "terragrunt + terratest" > /var/www/html/index.html
    SCRIPT
  }

}

data "google_storage_bucket_object_content" "key_server" {

  bucket = "ssita"
  name   = "ssh/id_rsa_server.pub"
}

variable "ssh_admin" {
  description = "OS user"
  default  = "wlad1324"
}

resource "google_compute_firewall" "firewall_server" {
	
  target_tags   = ["tag-terragrunt"]
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  name    = "terragrunt"
	network = "default"

  allow {
      protocol = "tcp"
      ports    = ["8080", "80", "9100"]
  }
}

