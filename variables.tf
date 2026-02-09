variable "resource_group" {
  type        = string
  default     = "mydevops"
  description = "My resource group"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "My resource location"
}

variable "storage_account" {
  type    = string
  default = "victorblaze-dev-storage-account"
}

variable "env" {
  type    = string
  default = "development"
}

variable "storage_container" {
  type    = string
  default = "appcontainer"
}

