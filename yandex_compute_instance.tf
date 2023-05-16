# ресурс "yandex_compute_instance" т.е. сервер
# Terraform будет знаеть его по имени "yandex_compute_instance.default"
resource "yandex_compute_instance" "bastion" {
  name        = "bastion-host"
  platform_id = "standard-v3" # тип процессора (Intel Ice Lake)

  resources {
    core_fraction = 20 # Гарантированная доля vCPU
    cores         = 2  # vCPU
    memory        = 1  # RAM
  }

  boot_disk {
    initialize_params {
      image_id = "fd8s56jeuvv3pe3niji7" # ОС (debian-11)
    }
  }

  network_interface {
    subnet_id = "e9biap0v36qvb11at3tt" # подсеть skillfactory-ru-central1-a 
    nat       = true                   # автоматически установить динамический ip
  }

  metadata = {
    ssh-keys = "ssh-rsa"
  }
}

resource "yandex_compute_instance" "server" {
  name        = "server-1"
  platform_id = "standard-v3" # тип процессора (Intel Ice Lake)

  resources {
    core_fraction = 20 # Гарантированная доля vCPU
    cores         = 2  # vCPU
    memory        = 1  # RAM
  }

  boot_disk {
    initialize_params {
      image_id = "fd8s56jeuvv3pe3niji7" # ОС (debian-11)
    }
  }

  network_interface {
    subnet_id = "e9biap0v36qvb11at3tt" # подсеть skillfactory-ru-central1-a 
    nat       = false                  # автоматически установить динамический ip
  }

  metadata = {
    ssh-keys = "ssh-rsa"
  }
}

resource "yandex_mdb_postgresql_database" "postgresql" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql.id
  name       = "skillfactorydb"
  owner      = yandex_mdb_postgresql_user.postgresql.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  extension {
    name = "uuid-ossp"
  }
  extension {
    name = "xml2"
  }
}

resource "yandex_mdb_postgresql_user" "postgresql" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql.id
  name       = "zubarev"
  password   = "yjjnhjgbk"
}

resource "yandex_mdb_postgresql_cluster" "postgresql" {
  name        = "test"
  environment = "PRESTABLE"
  network_id  = "enpfks6n0olo7o378l7l"

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 16
    }
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = "e9biap0v36qvb11at3tt"
  }
}
