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

variable "pg_hostname" {
  description = "The hostname where your PostgreSQL service is accessible at."
  type        = string
  default     = null
}

variable "pg_port" {
  description = "The port where your PostgreSQL service is accessible at."
  type        = string
  default     = null
}

variable "pg_admin_username" {
  description = "Administrator/Root user to access your PostgreSQL service."
  type        = string
  default     = null
}

variable "pg_admin_password" {
  description = "Administrator/Root password to access your PostgreSQL service."
  type        = string
  default     = null
  sensitive   = true
}
