module "wireguard_instance" {
  source        = "./modules/ec2_instance"
  name          = "wireguard"
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  vpc_id        = var.vpc_id
  user_data     = templatefile("user_data.sh", {})
  tags = {
    project = "vpn"
  }
}

output "public_ip" {
  value = module.wireguard_instance.public_ip  
}