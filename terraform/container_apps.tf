# Backend Container App
resource "azurerm_container_app" "backend" {
  name                         = "${var.project_name}-backend"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  template {
    container {
      name   = "backend"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "DB_HOST"
        value = azurerm_postgresql_flexible_server.db.fqdn
      }
      env {
        name  = "DB_NAME"
        value = "friends"
      }
      env {
        name  = "DB_USER"
        value = var.db_admin_user
      }
      env {
        name        = "DB_PASSWORD"
        secret_name = "db-password"
      }
      env {
        name  = "DB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_DRIVER"
        value = "postgres"
      }
      env {
        name  = "SSLMODE"
        value = "require"
      }
    }
  }

  secret {
    name  = "db-password"
    value = var.db_admin_password
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [azurerm_container_app_environment.env]
}

# Frontend Container App
resource "azurerm_container_app" "frontend" {
  name                         = "${var.project_name}-frontend"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  template {
    container {
      name   = "frontend"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [azurerm_container_app_environment.env]
}
