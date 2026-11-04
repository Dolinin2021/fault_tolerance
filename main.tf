# Запрос самого актуального ID для оригинальной Ubuntu 22.04
data "yandex_compute_image" "ubuntu_latest" {
  family = "ubuntu-2204-lts"
}

# Создание сети
resource "yandex_vpc_network" "network_1" {
  name = "web-network"
}

# Создание подсети
resource "yandex_vpc_subnet" "subnet_1" {
  name           = "web-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network_1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# 1. Создание 2-х идентичных ВМ через count
resource "yandex_compute_instance" "web" {
  count = 2
  name  = "web-server-${count.index + 1}"
  zone  = var.yc_zone

  platform_id = "standard-v3" 

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_latest.id # Динамический ID вместо строки
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_1.id
    nat       = true
  }

  metadata = {
    user-data = file("${path.module}/meta.txt")
  }
}

# 2. Создание таргет-группы с динамическим добавлением ВМ
resource "yandex_lb_target_group" "web_tg" {
  name      = "web-target-group"
  region_id = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance.web
    content {
      subnet_id = yandex_vpc_subnet.subnet_1.id
      address   = target.value.network_interface.0.ip_address
    }
  }
}

# 3. Создание сетевого балансировщика нагрузки
resource "yandex_lb_network_load_balancer" "web_balancer" {
  name = "web-network-balancer"

  listener {
    name        = "http-listener"
    port        = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web_tg.id

    healthcheck {
      name = "http-healthcheck"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
