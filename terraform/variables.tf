variable "project_name" {
  type    = string
  default = "friends-app"
}

variable "location" {
  type    = string
  default = "japanwest"
}

variable "resource_group_name" {
  type    = string
  default = "rg-friends"
}

variable "acr_name" {
  type    = string
  default = "acrfriendsunique" # 世界中でユニークである必要があります
}

variable "db_admin_user" {
  type    = string
  default = "dbadmin"
}

variable "db_admin_password" {
  type      = string
  sensitive = true
}
