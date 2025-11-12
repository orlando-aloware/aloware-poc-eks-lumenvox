data "http" "ingress_nginx_eks_manifest" {
  url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.14.0/deploy/static/provider/aws/deploy.yaml"
}

resource "kubernetes_manifest" "ingress_nginx" {
  manifest = yamldecode(data.http.ingress_nginx_eks_manifest.body)
}
