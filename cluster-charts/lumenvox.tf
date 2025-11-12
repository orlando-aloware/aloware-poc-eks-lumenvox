# https://github.com/lumenvox/helm-charts/releases/download/lumenvox-6.2.2/lumenvox-6.2.2.tgz
resource "helm_release" "lumenvox" {
  name             = "lumenvox"
  chart            = "https://github.com/lumenvox/helm-charts/releases/download/lumenvox-6.2.2/lumenvox-6.2.2.tgz"
  namespace        = "lumenvox"
  create_namespace = true
}
