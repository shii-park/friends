output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "postgresql_fqdn" {
  value = azurerm_postgresql_flexible_server.db.fqdn
}

output "backend_url" {
  value = azurerm_container_app.backend.ingress[0].fqdn
}

output "frontend_url" {
  value = azurerm_container_app.frontend.ingress[0].fqdn
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}
