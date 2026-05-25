output "generated_files" {
  value       = [for name in sort(keys(local_file.generated_files)) : local_file.generated_files[name].filename]
  description = "Generated file paths written for this stack."
}
