//output "project_id" {
//  value       = module.gcp-project.project_id
//  description = "The ID of the created project"
//}

output "project" {
  value       = module.gcp-project
  description = "The full host project info"
}