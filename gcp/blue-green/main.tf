resource "google_service_account" "blue_green" {
  account_id   = "blue-green"
  display_name = "Blue Green Service Account"
}


##########################################################################
# Blue MIG
##########################################################################
resource "google_compute_instance_template" "blue_tpl" {

  name        = "blue-template"
  description = "This template is used to create blue instances."

  tags = ["blue"]

  labels = {
    environment = "dev"
  }

  instance_description = "blue instances"
  machine_type         = "e2-medium"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  disk {
    source      = google_compute_disk.blue.name
    auto_delete = false
    boot        = false
  }

  network_interface {
    network = "default"
  }

  metadata = {
    owner = "keyproco"
    startup-script = <<-SCRIPT
      #!/bin/bash
       apt-get update
       apt-get install -y nginx
       echo "Blue environment" > /var/www/html/index.html
    SCRIPT
  }

  service_account {
    email  = google_service_account.blue_green.email
    scopes = ["cloud-platform"]
  }
}

data "google_compute_image" "bg" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_disk" "blue" {

  name  = "blue-disk"
  image = data.google_compute_image.bg.self_link
  size  = 10
  type  = "pd-ssd"
  zone  = "us-west1-a"

}

resource "google_compute_instance_group_manager" "blue_mig" {

  version {
    instance_template = google_compute_instance_template.blue_tpl.self_link_unique
  }

  name               = "blue-mig"
  base_instance_name = "blue"

  target_size = 1
  zone        = "us-west1-a"

  #   auto_healing_policies {
  #   }
  depends_on = [ google_compute_router_nat.nat ]
}


##########################################################################
# Green MIG
##########################################################################
resource "google_compute_instance_template" "green" {

  name        = "green-template"
  description = "This template is used to create blue instances."

  tags = ["green"]

  labels = {
    environment = "dev"
  }

  instance_description = "green instances"
  machine_type         = "e2-medium"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  disk {
    source      = google_compute_disk.green.name
    auto_delete = false
    boot        = false
  }

  network_interface {
    network = "default"
  }

  metadata = {
    owner = "keyproco"
    startup-script = <<-SCRIPT
      #!/bin/bash
       apt-get update
       apt-get install -y nginx
       echo "Green environment" > /var/www/html/index.html
    SCRIPT
  }

  service_account {
    email  = google_service_account.blue_green.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_disk" "green" {

  name  = "green-disk"
  image = data.google_compute_image.bg.self_link
  size  = 10
  type  = "pd-ssd"
  zone  = "us-west1-a"

}

resource "google_compute_instance_group_manager" "green_mig" {

  version {
    instance_template = google_compute_instance_template.green.self_link_unique
  }

  name               = "green-mig"
  base_instance_name = "green"

  target_size = 1
  zone        = "us-west1-a"

  #   auto_healing_policies {
  #   }
  depends_on = [ google_compute_router_nat.nat,
                #  google_storage_bucket.html_bucket,
                #  google_storage_bucket_object.blue,
                #  google_storage_bucket_object.green
   ]
}
##########################################################################
# Fast Network setup
##########################################################################

data "google_compute_network" "default_net" {
  name = "default"
}

resource "google_compute_router" "router" {
  name    = "keyproland-router"
  network = data.google_compute_network.default_net.name
}

resource "google_compute_router_nat" "nat" {
  name                               = "keyproland-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

####################################################
# Lack of gcs permissions
# resource "google_storage_bucket" "html_bucket" {
#   name          = "bg-ake"
#   location      = "US"
#   force_destroy = true

#   public_access_prevention = "enforced"
# }

# resource "google_storage_bucket_object" "blue" {
#   name   = google_storage_bucket.html_bucket.name
#   source = ""
#   bucket = "image-store"
#   depends_on = [ google_storage_bucket.html_bucket ]
# }

# resource "google_storage_bucket_object" "green" {
#   name   = google_storage_bucket.html_bucket.name
#   source = ""
#   bucket = "image-store"
#   depends_on = [ google_storage_bucket.html_bucket ]
# }