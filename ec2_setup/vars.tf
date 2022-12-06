
variable "aws_region" {
  default = "eu-central-1"
}


variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public  = 2,
    private = 2
  }
}

variable "settings" {
  description = "Configuration settings"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage   = 10
      engine              = "mysql"
      engine_version      = "8.0.27"
      instance_class      = "db.t2.micro"
      db_name             = "jenkins"
      skip_final_snapshot = true
    },
    "web_app" = {
      count         = 2          // the number of EC2 instances
      instance_type = "t2.micro" // the EC2 instance
    }
  }
}

variable "public_subnet_cidr_blocks" {
  description = "Available CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.1.1.0/24",
    "10.1.2.0/24",
    "10.1.3.0/24",
    "10.1.4.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.1.5.0/24",
    "10.1.6.0/24",
    "10.1.7.0/24",
    "10.1.8.0/24",
  ]
}

variable "my_ip" {
  description = "Your IP address"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database master user"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master user password"
  type        = string
  sensitive   = true
}