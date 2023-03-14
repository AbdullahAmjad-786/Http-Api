variable "location" {
    type = string
    description = "Location of the resource."
    default = "eastus"
}

variable "db_username" {
    type = string
    description = "MySQL database username."
    default = "admin"
}

variable "db_password" {
    type = string
    description = "MySQL database password."
    default = "admin1234"
}
