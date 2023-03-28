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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.19.0"
    }
  }
}

# --------------------------------------------------------------------------
# Create k8s Namespace
# --------------------------------------------------------------------------
resource "kubernetes_namespace" "nxrm" {
  metadata {
    name = local.namespace
    annotations = {
      "nxrm_purpose" = "${var.nxrm_name}"
    }
  }
}

# --------------------------------------------------------------------------
# Create k8s Secrets
# --------------------------------------------------------------------------
resource "kubernetes_secret" "nxrm" {
  metadata {
    name      = "nxrm-secrets"
    namespace = local.namespace
    annotations = {
      "nxrm_purpose" = "${var.nxrm_name}"
    }
  }

  binary_data = {
    "license.lic" = filebase64("${var.nxrm_license_file}")
  }

  data = {
    "db_password" = var.db_password
  }

  type = "Opaque"
}

# --------------------------------------------------------------------------
# Create k8s Deployment
# --------------------------------------------------------------------------
resource "kubernetes_deployment" "nxrm3" {
  metadata {
    name      = "nxrm3-ha-${var.nxrm_name}"
    namespace = local.namespace
    labels = {
      app = "nxrm3-ha"
    }
  }
  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = "nxrm3-ha"
      }
    }

    template {
      metadata {
        labels = {
          app = "nxrm3-ha"
        }
      }

      spec {
        node_selector = {
          instancegroup = "shared"
        }

        init_container {
          name    = "chown-nexusdata-owner-to-nexus-and-init-log-dir"
          image   = "busybox:1.33.1"
          command = ["/bin/sh"]
          args = [
            "-c",
            ">- mkdir -p /nexus-data/etc/logback && mkdir -p /nexus-data/log/tasks && mkdir -p /nexus-data/log/audit && touch -a /nexus-data/log/tasks/allTasks.log && touch -a /nexus-data/log/audit/audit.log && touch -a /nexus-data/log/request.log && chown -R '200:200' /nexus-data"
          ]
        }

        container {
          image             = "sonatype/nexus3:${var.nxrm_version}"
          name              = "nxrm3-app"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "DB_HOST"
            value = var.db_hostname
          }

          env {
            name  = "DB_NAME"
            value = var.db_database
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "nxrm-secrets"
                key  = "pgsql_password"
              }
            }
          }

          env {
            name  = "DB_PORT"
            value = var.db_port
          }

          env {
            name  = "DB_USER"
            value = var.db_username
          }

          env {
            name  = "NEXUS_SECURITY_RANDOMPASSWORD"
            value = false
          }

          env {
            name  = "INSTALL4J_ADD_VM_PARAMS"
            value = "-Xms2703m -Xmx2703m -XX:MaxDirectMemorySize=2703m -Dnexus.licenseFile=/nxrm3-secrets/license.lic -Dnexus.datastore.enabled=true -Djava.util.prefs.userRoot=$${NEXUS_DATA}/javaprefs -Dnexus.datastore.nexus.jdbcUrl=jdbc:postgresql://$${DB_HOST}:$${DB_PORT}/$${DB_NAME} -Dnexus.datastore.nexus.username=$${DB_USER} -Dnexus.datastore.nexus.password=$${DB_PASSWORD} -Dnexus.datastore.clustered.enabled=true"
          }

          port {
            container_port = 8081
          }

          security_context {
            run_as_user = 200
          }

          volume_mount {
            mount_path = "/nxrm3-secrets"
            name       = "nxrm3-secrets"
          }
        }

        volume {
          name = "nxrm3-secrets"
          secret {
            secret_name = "sonatype-nxrm3"
          }
        }
      }
    }
  }
}

# --------------------------------------------------------------------------
# Create k8s Service
# --------------------------------------------------------------------------
resource "kubernetes_service" "nxrm3" {
  metadata {
    name      = "nxrm3-ha-${var.nxrm_name}-svc"
    namespace = local.namespace
    labels = {
      app = "nxrm3-ha"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.nxrm3.metadata.0.labels.app
    }

    port {
      name        = "http"
      port        = 8081
      target_port = 8081
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}
