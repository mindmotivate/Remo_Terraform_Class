### VPC Configuration:
**Create a Virtual Private Cloud (VPC) to host all your resources. Utilize a CIDR block that supports a sufficient number of subnets and IP addresses for your application.**

**Per RFC 1918:**
- **10.0.0.0/8:** Largest address space (over 16 million addresses).Preferred for large-scale deployments by cloud providers like AWS, Azure, and Google Cloud.
- **172.16.0.0/12:** Moderate address space (over 1 million addresses).Used for medium-scale deployments or organizations needing more than a /16 but less than /8.
- **192.168.0.0/16:** Smaller address space (over 65,000 addresses).Suitable for small-scale deployments, home networks, or environments needing a limited number of addresses.*

The VPC in AWS will have a IPv4 CIDR block "10.0.0.0/16" as its default
You can assign VPC with a IPv4 CIDR block such as  "10.10.0.0/16". 
This simply means that all your Ip address in your VPC will start with: "10.10.x.x" instead of "10.0.x.x".

Here are some general guidelines per cloud provider:

- **AWS: 10.1-99.0.0/16**
- Azure: 10.200-255.0.0/16
- Google Cloud/Oracle: 10.10-199.0.0/16

The following block provides a range of IP addresses from 10.10.0.0 to 10.0.255.255, allowing for up to 65,536 IP addresses.

> *Note: The DNS arguments (enable_dns_support and enable_dns_hostnames) are not required, but they are commonly enabled for most VPC configurations to facilitate DNS resolution and hostname assignment within the VPC. 
However, if your use case doesn't require DNS support or hostnames, you can omit these arguments or set them to false.*

```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.10.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}
```

### Subnet Design:
Divide your VPC's CIDR block into subnets using the cidrsubnet function. You must create at least three public and three private subnets across different Availability Zones for high availability.

> *Note: High availability in AWS involves deploying resources across multiple Availability Zones (AZs) within a region. 
By doing so, you ensure redundancy and fault tolerance, minimizing the impact of failures or disruptions in any single AZ.*

By using the "cidrsubnet" function in terraform we can create both private and public subnets if we choose:

```hcl
resource "aws_subnet" "public_subnet" {
  count             = 3 #we want to create 3 public subnets
  vpc_id            = aws_vpc.my_vpc.id #we are associating it with the vpc we created above
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index * 2) #this function calculates the CIDR blocks
  availability_zone = "us-east-1${element(["a", "b", "c"], count.index)}" #we want our subnet to be in us-east-1
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# the private subnet configuration will be very similar
resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index * 2 + 1)
  availability_zone = "us-east-1${element(["a", "b", "c"], count.index)}"
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}
```

### Gateway Establishment:
Establish an **Internet Gateway** to connect your VPC with the internet.

An Internet Gateway is used to connect the VPC with the internet.
The aws_internet_gateway resource creates an internet gateway and associates it with the VPC specified by vpc_id.

> *Note: The static nature of the IGW's public IP address is crucial for maintaining consistent inbound and outbound internet communication for resources within the VPC. 
It ensures that external systems can reliably route traffic to and from the VPC using the IGW's fixed IP address.

```hcl
resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.my_vpc.id #The IGW is associated with the VPC named my_vpc.
}
```

Set up a **NAT Gateway** to allow instances in the private subnets to access the internet while maintaining their privacy.

*Note: When a resource in a private subnet needs to communicate with the internet (e.g., to download updates), it sends its outbound traffic to the NAT Gateway.*

```hcl
resource "aws_eip" "my_eip" {
domain = "vpc"
count = 3
}
```
*The EIP's created, will be assigned to the private subnets

```hcl
resource "aws_nat_gateway" "my_nat_gateway" {
  count          = 3
  allocation_id  = aws_eip.my_eip[count.index].id
  subnet_id      = aws_subnet.public_subnet[count.index].id
  depends_on = [aws_internet_gateway.my_ig]
}
```

## Creating Routes:

Configure appropriate route tables for public and private subnets. Ensure that instances in public subnets can directly access the internet, while instances in private subnets use the NAT Gateway.

Route tables in cloud networking specify how traffic should be directed within a VPC. 

```hcl
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id #It associates the route table with the vpc

  route {
    cidr_block = "0.0.0.0/0" #This is used for outbound traffic from the instances within the subnet to the IGW
    gateway_id = aws_internet_gateway.my_ig.id # allows instances in public subnets to access the internet 
  }
}
```

*Note: For the private subnet: The traffic is directed to the NAT Gateway, which then facilitates outbound internet access for instances in the private subnet
by translating their private IP addresses to the public IP address of the NAT Gateway*


```hcl
resource "aws_route_table" "private_route_table" {
  count = 3
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway[count.index].id
  }
}
```

## Security Groups:
Define security groups for your application servers and load balancers. At a minimum, allow inbound HTTP and HTTPS traffic, alongside SSH and RDP for management.

*Note: This aligns with RFC 1918, which recommends using private IP address ranges within a network and implementing measures to control traffic flow 
between internal and external networks, ensuring network security and privacy.*


```hcl
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### EC2 Instances and Scaling:

Utilize a launch template for EC2 instances. Your template should specify instance types, the AMI ID, security groups, and any user data initialization scripts.
Implement an Auto Scaling group that adjusts the number of instances based on demand, with specified minimum, maximum, and desired capacities.

*Note: The aws_launch_template resource is used to define the specifications for EC2 instances, including instance type, 
AMI ID, security groups, and user data initialization scripts.*

### Launch Template

```hcl
resource "aws_launch_template" "my_launch_template" {
  name          = "first-template"
  image_id      = "ami-051f8a213df8bc089"
  instance_type = "t2.micro"
  key_name      = "secure"

  # This code has been intentionally commented out
  # This is definitely not required however I was curious to see how I could encorprate EBS should I ever need to
/*
  block_device_mappings {
    device_name = "/dev/sda1"
    
    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }
  */


  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }


    vpc_security_group_ids = [aws_security_group.web_sg.id]


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "first template"
    }
  }

  # User data script for initialization, properly formatted and encoded in BASE64
  user_data = base64encode(<<EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to the Remo Terraform Web Server</h1>" > /var/www/html/index.html
EOF
  )

  lifecycle {
    create_before_destroy = true
  }

}

```

### Load Balancer:

Deploy an Application Load Balancer (ALB) to distribute incoming traffic among your instances. 

*To be more precise, an Application Load Balancer intelligently distributes incoming application traffic across multiple targets, such as EC2 instances which are spread out amongst multiple Az's*

*Note: Public internet traffic typically comes in via Layer 7 protocols such as HTTP and HTTPS. These protocols are commonly used for web-based applications and services, 
allowing clients to communicate with servers over the internet using standardized request-response patterns*

```hcl
resource "aws_lb" "load_balancer" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public_subnet[*].id
}
```

### Target Group:

Configure a target group for the ALB, specifying health check parameters to ensure traffic is only sent to healthy instances.

*Note: the direct association isn't present in the target group resource itself, it's established indirectly through the listener configuration on the ALB
The target group works in conjunction with the ALB to distribute incoming traffic among the instances that are registered with it. 
It continuously monitors the health of the instances using the defined health check parameters and routes traffic only to healthy instances, 
ensuring high availability and reliability of the application.*

```hcl
resource "aws_lb_target_group" "target_group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher = "200"
  }
}
```

### Auto Scaling Group & Scaling Policies:
Create a scaling policy based on CPU utilization, aiming for an average target value. This policy should automatically scale the number of instances in your Auto Scaling group.

*Note: Public subnet instances are typically exposed to incoming internet traffic, which can vary and be unpredictable. 
Therefore, it's essential to dynamically adjust the number of instances in response to fluctuations in demand to maintain performance and availability.*


```hcl
resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "autoscaling-group"
  launch_template {
    id                      = aws_launch_template.my_launch_template.id
    version                 = "$Latest"
  }
  min_size                  = 3
  max_size                  = 8
  desired_capacity          = 6
  vpc_zone_identifier       = aws_subnet.public_subnet[*].id
  health_check_type          = "EC2"
  health_check_grace_period  = 300
  force_delete               = true
  target_group_arns          = [aws_lb_target_group.target_group.arn]

  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]

  # Instance protection for launching
  initial_lifecycle_hook {
    name                  = "instance-protection-launch"
    lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
    default_result        = "CONTINUE"
    heartbeat_timeout     = 60
    notification_metadata = "{\"key\":\"value\"}"
  }

  # Instance protection for terminating
  initial_lifecycle_hook {
    name                  = "scale-in-protection"
    lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
    default_result        = "CONTINUE"
    heartbeat_timeout     = 300
  }

  tag {
    key                 = "Name"
    value               = "app1-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }

}
```

### Target Group
```hcl
resource "aws_lb_target_group" "target_group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher = "200"
  }
}
```

### Scaling Policy
```hcl
resource "aws_autoscaling_policy" "scaling_policy" {
  name                   = "scaling-policy"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 120
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

### Enabling instance scale-in protection:
resource "aws_autoscaling_attachment" "autoscaling_group_attachment" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  lb_target_group_arn   = aws_lb_target_group.target_group.arn
}
```

### Listener

*Note: By setting up the listener in this way, any incoming traffic to the ALB on port 80 (HTTP) will be forwarded to the target group 
target_group, allowing the ALB to communicate with the instances registered in that target group*

```hcl
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
```


### Output:
Output the DNS name of the load balancer, also allow users to access your web application via a clickable link.

```hcl
output "load_balancer_dns" {
  value = aws_lb.load_balancer.dns_name
}

output "load_balancer_dns_url_link" {
  value = "http://${aws_lb.load_balancer.dns_name}"
}
```






