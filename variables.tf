variable "yc_service_account_key_file" {
  type        = string
  description = "Путь к JSON-файлу с авторизованным ключом сервисного аккаунта"
}


variable "yc_cloud_id" {
  type        = string
  description = "ID вашего Облака (Cloud ID)"
}

variable "yc_folder_id" {
  type        = string
  description = "ID вашего Каталога (Folder ID)"
}

variable "yc_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "Зона доступности для ресурсов"
}
