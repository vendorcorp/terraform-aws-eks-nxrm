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

variable "database_name_prefix" {
  description = "Prefix for the PostgreSQL database name."
  type        = string
  default     = "nxrm"
}

variable "target_namespace" {
  description = "Namespace in which to deploy Sonatype IQ Server"
  type        = string
  default     = null
  validation {
    condition     = length(regex("[A-Za-z][0-9A-Za-z-]{4,}", var.target_namespace)) > 4
    error_message = "Target namespace should be longer than 6 characters"
  }
}

variable "storage_class_name" {
  description = "Storage Class to use for PVs - must support 'ReadWriteMany' mode."
  type        = string
  default     = null
  validation {
    condition     = var.storage_class_name != null
    error_message = "Storage Class must be set."
  }
}

variable "storage_volume_size" {
  description = "Size of the PV for Sonatype IQ Server"
  type        = string
  default     = "5Gi"
}

variable "purpose" {
  description = "Helpful description of the purpose / use for this Sonatype IQ Server"
  type        = string
  validation {
    condition     = length(var.purpose) > 6
    error_message = "Purpose for this Sonatype IQ must be 6 or more characters."
  }
}

variable "nxrm_license_data" {
  description = "Sonatype License data for Nexus Repository Manager Pro (base64 encoded)."
  type        = string
  validation {
    condition     = length(var.nxrm_license_data) > 50
    error_message = "License data is likely incomplete - it is very short!"
  }
}

variable "nxrm_version" {
  description = "Version of Sonatype Nexus Repository to deploy."
  type        = string
  default     = "3.64.0"
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