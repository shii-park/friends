resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "${var.project_name}-db-server"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "16"
  administrator_login    = var.db_admin_user
  administrator_password = var.db_admin_password
  zone                   = "1"

  storage_mb = 32768
  sku_name   = "B_Standard_B1ms" # 開発・テスト用の最小スペック

  public_network_access_enabled = true # 本番では Private Link 推奨
}

resource "azurerm_postgresql_flexible_server_database" "friends" {
  name      = "friends"
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Azure 内部サービスからのアクセスを許可
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
