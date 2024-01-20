variable "vpc_name" {
    type = string
  
}
variable "subnetwork" {
    type = string  
}
variable "subnetwork_range" {
  type = string
}
variable "region" {
  type = string
  default = "europe-west4"
}
variable "connector_range" {
    type = string  
}
variable "job_name" {
    type = string  
}
variable "image" {
    type = string  
}
variable "schedule" {
    type = string  
}
variable "connector_name" {
    type = string  
}
variable "project" {
    type = string  
}
variable "sa" {
    type = string  
}
variable "scheduler_name" {
    type = string
  
}
