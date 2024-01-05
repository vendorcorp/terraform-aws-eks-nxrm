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

module "nxrm_pg_database" {
  source            = "git::ssh://git@github.com/vendorcorp/terraform-aws-rds-database.git?ref=v0.1.0"

  pg_hostname       = var.pg_hostname
  pg_port           = var.pg_port
  pg_admin_username = var.pg_admin_username
  pg_admin_password = var.pg_admin_password
  database_name     = "${var.database_name_prefix}-${local.database_name_suffix}"
  user_username     = "${var.database_name_prefix}-${local.database_name_suffix}"
  # Password generated and returned
}
