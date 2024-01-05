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
# Create k8s Namespace
# --------------------------------------------------------------------------
resource "kubernetes_namespace" "nxrm" {
  metadata {
    name        = var.target_namespace
    annotations = {
      "nxrm.sonatype.com/cluster-id"  = local.identifier
      "nxrm.sonatype.com/purpose"     = var.purpose
    }
  }
}

# --------------------------------------------------------------------------
# Create k8s Secrets
# --------------------------------------------------------------------------
resource "kubernetes_secret" "nxrm" {
  metadata {
    name        = "nxrm-secrets"
    namespace   = var.target_namespace
    annotations = {
      "nxrm.sonatype.com/cluster-id"  = local.identifier
      "nxrm.sonatype.com/purpose"     = var.purpose
    }
  }

  binary_data = {
    "license.lic"   = filebase64("${var.nxrm_license_file}")
  }

  data = {
    "psql_password" = module.nxrm_pg_database.user_password
  }

  type = "Opaque"
}

# --------------------------------------------------------------------------
# Create k8s PVC
# --------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim" "nxrm3" {
  metadata {
    generate_name = "nxrm3-data-"
    namespace     = var.target_namespace
    annotations = {
      "nxrm.sonatype.com/cluster-id"  = local.identifier
      "nxrm.sonatype.com/purpose"     = var.purpose
    }
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.storage_volume_size
      }
    }
  }
}

# --------------------------------------------------------------------------
# Create k8s Deployment
# --------------------------------------------------------------------------
resource "kubernetes_deployment" "nxrm3" {
  metadata {
    name            = "nxrm3-ha"
    namespace       = var.target_namespace
    annotations     = {
      "nxrm.sonatype.com/cluster-id"  = local.identifier
      "nxrm.sonatype.com/purpose"     = var.purpose
    }
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
        # init_container {
        #   name    = "chown-nexusdata-owner-to-nexus-and-init-log-dir"
        #   image   = "busybox:1.33.1"
        #   command = ["/bin/sh"]
        #   args = [
        #     "-c",
        #     ">- mkdir -p /nexus-data/etc/logback && mkdir -p /nexus-data/log/tasks && mkdir -p /nexus-data/log/audit && touch -a /nexus-data/log/tasks/allTasks.log && touch -a /nexus-data/log/audit/audit.log && touch -a /nexus-data/log/request.log && chown -R '200:200' /nexus-data"
        #   ]
        # }

        container {
          image             = "sonatype/nexus3:${var.nxrm_version}"
          name              = "nxrm3-app"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "DB_HOST"
            value = var.pg_hostname
          }

          env {
            name  = "DB_NAME"
            value = module.nxrm_pg_database.user_username
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "nxrm-secrets"
                key  = "psql_password"
              }
            }
          }

          env {
            name  = "DB_PORT"
            value = var.pg_port
          }

          env {
            name  = "DB_USER"
            value = module.nxrm_pg_database.user_username
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

          volume_mount {
            mount_path = "/nexus-blob-storage"
            name       = "nxrm3-data"
          }
        }

        volume {
          name = "nxrm3-secrets"
          secret {
            secret_name = "nxrm-secrets"
          }
        }

        volume {
          name = "nxrm3-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.nxrm3.metadata[0].name
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
    name          = "nxrm3-svc"
    namespace     = var.target_namespace
    annotations   = {
      "nxrm.sonatype.com/cluster-id"  = local.identifier
      "nxrm.sonatype.com/purpose"     = var.purpose
    }
    labels        = {
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