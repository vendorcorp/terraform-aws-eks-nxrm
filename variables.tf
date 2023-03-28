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

variable "default_resource_tags" {
  description = "List of tags to apply to all resources created in AWS"
  type        = map(string)
  default     = {}
}

variable "nxrm_name" {
  description = "Helpful friendly name for this NXRM Cluster (min 8 alpha characters)"
  type        = string
  validation {
    condition     = length(regex("[[:alpha:]]{6,}", var.nxrm_name)) > 6
    error_message = "Name for this NXRM must be 6 or more alpha characters."
  }
}

variable "nxrm_license_file" {
  description = "Path to a valid Sonatype License file for Nexus Repository Manager Pro."
  type        = string
  validation {
    condition     = length(var.nxrm_license_file) > 5
    error_message = "Name for this NXRM must be 6 or more alpha characters."
  }
}

variable "nxrm_version" {
  description = "Version of NXRM to deploy."
  type        = string
  default     = "3.50.0"
  validation {
    condition     = length(var.nxrm_version) > 5
    error_message = "Version must be supplied as X.Y.Z to match the Docker Image Tag."
  }
}

variable "replica_count" {
  description = "Number of replicas to run in the Active-Active NXRM HA Cluster."
  type        = number
  default     = 1
  validation {
    condition     = var.replica_count > 0
    error_message = "Replica Count must be greater than zero."
  }
}

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

variable "create_database" {
  description = "Whether a unique database will be created for this NXRM Cluster."
  type        = bool
  default     = true
  validation {
    condition     = var.create_database == true
    error_message = "Only true is currently supported for create_database!"
  }
}
