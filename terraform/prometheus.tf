# resource "helm_release" "prometheus" {
#   name       = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "prometheus"
#   namespace  = "prometheus"

#   create_namespace = true

#   set {
#     name  = "alertmanager.persistentVolume.storageClass"
#     value = "gp2"
#   }

#   set {
#     name  = "server.persistentVolume.storageClass"
#     value = "gp2"
#   }
# }