# Linkerd Service Mesh Installation
# Note: Only Linkerd versions up to edge-24.5.5 are supported by LumenVox

# Linkerd CRDs
resource "helm_release" "linkerd_crds" {
  name             = "linkerd-crds"
  repository       = "https://helm.linkerd.io/edge"
  chart            = "linkerd-crds"
  version          = "edge-24.5.5"
  namespace        = "linkerd"
  create_namespace = true

  depends_on = []
}

# Linkerd Control Plane
resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  repository = "https://helm.linkerd.io/edge"
  chart      = "linkerd-control-plane"
  version    = "edge-24.5.5"
  namespace  = "linkerd"

  set {
    name  = "proxyInit.runAsRoot"
    value = "true"
  }

  depends_on = [helm_release.linkerd_crds]
}

# Linkerd Viz (Dashboard and Metrics)
resource "helm_release" "linkerd_viz" {
  name       = "linkerd-viz"
  repository = "https://helm.linkerd.io/edge"
  chart      = "linkerd-viz"
  version    = "edge-24.5.5"
  namespace  = "linkerd-viz"
  create_namespace = true

  depends_on = [helm_release.linkerd_control_plane]
}

# Linkerd Jaeger (Distributed Tracing)
resource "helm_release" "linkerd_jaeger" {
  name       = "linkerd-jaeger"
  repository = "https://helm.linkerd.io/edge"
  chart      = "linkerd-jaeger"
  version    = "edge-24.5.5"
  namespace  = "linkerd-jaeger"
  create_namespace = true

  depends_on = [helm_release.linkerd_control_plane]
}
