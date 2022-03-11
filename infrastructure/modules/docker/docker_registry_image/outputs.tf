output "image_uri" {
  description = "The Docker image URI"
  value       = docker_registry_image.this.name
}