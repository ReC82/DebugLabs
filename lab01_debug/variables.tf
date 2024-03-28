variable "group_name" {
  description = "group name of the lab"
  default     = "ansible_group"
}

variable "group_location" {
  default = "centralus"
}

variable "node_count" {
  description = "Number of nodes"
  type        = number

  default     = 3  

  validation {
    condition = var.node_count <= 6  
    error_message = "node_count must be less than or equal to 6"
  }
}

/*
variable "node_info" {
  type = list(map(string)) 
  default = [
    {
      "type" = "web"
    },
    {
      "type" = "db"
    },
    {
      "type" = "api"
    }
  ]
}*/

variable "node_names" {
  description = "Map of node names"
  type        = map(string)
  default = {
    0 = "alpha"
    1 = "beta"
    2 = "gamma"
    3 = "delta"
    4 = "epsilon"
    5 = "zeta"
  }
}

variable "security_groups" {
  description = "Map of Security Groups"
  type        = map(string)
  default = {
    0 = "web"
    1 = "database"
    2 = "control"
  }
}

#variable "lab_ansible_01" {
#  description = "group name of the lab"
#  default     = file("sublab_ansible/lab01/pb2.yaml")
#}

