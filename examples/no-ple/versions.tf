terraform {
  required_version = "~> 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.54.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.54.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}