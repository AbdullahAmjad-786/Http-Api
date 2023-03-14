# Create Key Vault for secrets management
resource "azurerm_key_vault" "key_vault" {
name                = "app-keyvault"
location            = azurerm_resource_group.app_rg.location
resource_group_name = azurerm_resource_group.app_rg.name

sku_name = "standard"

access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = [  "get",  "list"]
  }
}

# Create secrets in Key Vault
resource "azurerm_key_vault_secret" "database_url" {
name         = "db-url"
value        = "mysql://root@${azurerm_mysql_server.mysql_server.fqdn}/${azurerm_mysql_database.mysql_db.name}?tls=true"
key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "db_user" {
name         = "db-user"
value        = var.db_username
key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "db_password" {
name         = "db-password"
value        = var.db_password
key_vault_id = azurerm_key_vault.key_vault.id
}
