# --------------------------------------------------------------------------
#
# Copyright 2023-Present Sonatype Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# --------------------------------------------------------------------------

# --------------------------------------------------------------------------
# Require a minimum version of Terraform and Providers
# --------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.6.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.15.0"
    }
  }
}

# --------------------------------------------------------------------------
# Create a unique database for NXRM
# --------------------------------------------------------------------------
resource "postgresql_role" "nxrm" {
  name     = local.pg_user_username
  login    = true
  password = local.pg_user_password
}

resource "postgresql_grant_role" "grant_root" {
  role              = var.pg_admin_username
  grant_role        = postgresql_role.nxrm.name
  with_admin_option = true
}

resource "postgresql_database" "nxrm" {
  name              = local.pg_database_name
  owner             = local.pg_user_username
  template          = "template0"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}
