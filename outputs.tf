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

output "nxrm_ha_k8s_namespace" {
  value = module.nxrm_ha_cluster.nxrm_ha_k8s_namespace
}

output "nxrm_ha_k8s_service_id" {
  value = module.nxrm_ha_cluster.nxrm_ha_k8s_service_id
}

output "nxrm_ha_k8s_service_name" {
  value = module.nxrm_ha_cluster.nxrm_ha_k8s_service_name
}
