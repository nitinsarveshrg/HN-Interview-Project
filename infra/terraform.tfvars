aws_region = "us-east-1"

services = [
  {
    name           = "hn-interview-app"
    image_url      = "latest"
    container_port = 3000
  }
]
