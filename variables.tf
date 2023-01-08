variable "vpc_cidr" {
  type    = string
  default = "10.123.0.0/16"
}

variable "public_route" {
  type    = string
  default = "0.0.0.0/0"
}

# variable "public_cidrs" {
#     type = list(string)
#     default = ["10.123.2.0/24", "10.123.4.0/24"]
# }

variable "pub_subnet_cnt" {
  type    = number
  default = 1
}

variable "priv_subnet_cnt" {
  type    = number
  default = 1
}

variable "access_from" {
  type    = string
  default = "0.0.0.0/0"
}

variable "access_to" {
  type    = string
  default = "0.0.0.0/0"
}

variable "t2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vol_size_t2" {
  type    = number
  default = 8
}

variable "count_t2" {
  type    = number
  default = 1
}

variable "value4subnet_deployment" {
  type    = number
  default = 20
}

variable "key_name" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "ports" {
  type    = list(number)
  default = [22, 80, 443, 3000, 9090, 8080]
}
