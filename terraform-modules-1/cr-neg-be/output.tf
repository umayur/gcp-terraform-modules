output "cloud_run_name" {

  value = google_cloud_run_v2_service.this.name

}

output "neg_id" {

  value = google_compute_region_network_endpoint_group.this.id

}

output "backend_id" {

  value = google_compute_region_backend_service.this.id

}

output "backend_self_link" {

  value = google_compute_region_backend_service.this.self_link

}