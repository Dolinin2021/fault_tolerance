output "balancer_public_ip" {
  description = "Публичный IP-адрес сетевого балансировщика"
    value = one(one(yandex_lb_network_load_balancer.web_balancer.listener).external_address_spec).address
}
