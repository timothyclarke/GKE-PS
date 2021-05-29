# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.1"
  project_id   = var.project_id
  network_name = var.network

  subnets = [
    {
      subnet_name   = var.subnetwork
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (var.subnetwork) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

module "gke" {
  source                      = "terraform-google-modules/kubernetes-engine/google"
  project_id                  = var.project_id
  name                        = "gke-test-1"
  regional                    = true
  region                      = var.region
  network                     = module.gcp-network.network_name
  subnetwork                  = module.gcp-network.subnets_names[0]
  ip_range_pods               = var.ip_range_pods_name
  ip_range_services           = var.ip_range_services_name
  create_service_account      = false
  service_account             = format("sa-189@%s.iam.gserviceaccount.com",var.project_id)
#  service_account             = var.compute_engine_service_account
  horizontal_pod_autoscaling  = true
  enable_binary_authorization = var.enable_binary_authorization
  skip_provisioners           = var.skip_provisioners

}
