resource "aws_instance" "host" {
    ami = "ami-0b6c6ebed2801a5cb"
    instance_type = "t3.micro"
    tags = {
      project = "deployment"
    }
}