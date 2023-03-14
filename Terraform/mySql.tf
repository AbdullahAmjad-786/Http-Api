# Create an Azure Database for MySQL server
resource "azurerm_mysql_server" "mysql_server" {
  name                = "mysql-server"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  sku_name            = "GP_Gen5_2"
  storage_mb          = 5120
  version             = "5.7"

  administrator_login          = var.db_username
  administrator_login_password = var.db_password

  auto_grow_enabled = true

  tags = {
    environment = "dev"
  }
}

# Create a firewall rule for the Azure Database for MySQL server
resource "azurerm_mysql_firewall_rule" "mysql_firewall_rule" {
  name                = "mysql-fw-rule"
  resource_group_name = azurerm_resource_group.app_rg.name
  server_name         = azurerm_mysql_server.mysql_server.name

  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
