aws_region = "us-east-1"

services = [
  {
    name           = "hn-interview-app"
    image_url      = "1138699031574.dkr.ecr.us-east-1.amazonaws.com/hn-interview-project:latest"
    container_port = 3000
  }
]
