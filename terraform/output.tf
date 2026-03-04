output "instance_ip" {
    value = aws_instance.demo_instance_public.id
}
output "private_instance_ip" {
    value = aws_instance.demo_instance_public.id
}