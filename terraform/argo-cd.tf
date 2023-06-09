module "gke_auth" {
  depends_on           = [time_sleep.wait_for_kube]
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  project_id           = var.project_id
  cluster_name         = google_container_cluster.default.name
  location             = var.zone
  use_private_endpoint = false
}

provider "kubectl" {
  host                   = module.gke_auth.host
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  token                  = module.gke_auth.token
  load_config_file       = false
}

data "kubectl_file_documents" "namespace" {
    content = file("../argocd-bootstrapping/namespace.yaml")
} 

data "kubectl_file_documents" "argocd" {
    content = file("../argocd-bootstrapping/install.yaml")
}

resource "kubectl_manifest" "namespace" {
    count     = length(data.kubectl_file_documents.namespace.documents)
    yaml_body = element(data.kubectl_file_documents.namespace.documents, count.index)
    override_namespace = "argocd"
}

resource "kubectl_manifest" "argocd" {
    depends_on = [
      kubectl_manifest.namespace,
    ]
    count     = length(data.kubectl_file_documents.argocd.documents)
    yaml_body = element(data.kubectl_file_documents.argocd.documents, count.index)
    override_namespace = "argocd"
}

data "kubectl_file_documents" "app-of-apps" {
    content = file("../argocd-bootstrapping/app-of-apps.yaml")
}

resource "kubectl_manifest" "app-of-apps" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.app-of-apps.documents)
    yaml_body = element(data.kubectl_file_documents.app-of-apps.documents, count.index)
    override_namespace = "argocd"
}