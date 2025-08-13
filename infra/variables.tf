variable "aws_region" { default = "us-east-1" }

# Each service: name, image URL, container port
variable "services" {
  type = list(object({
    name           = string
    image_url      = string
    container_port = number
  }))
}

variable "cpu"           { default = 256 }
variable "memory"        { default = 512 }
variable "desired_count" { default = 1 }
