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

resource "random_string" "identifier" {
  length  = 12
  special = false
}

resource "random_string" "pg_suffix" {
  length  = 10
  special = false
}

locals {
  database_name_suffix  = random_string.pg_suffix.result
  identifier            = "nxrm-${lower(random_string.identifier.result)}"
}
