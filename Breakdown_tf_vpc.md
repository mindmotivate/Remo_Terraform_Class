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
  count = 3 #ensures that three NAT Gateways and three corresponding EIPs are created, one for each Availability Zone.
}
```
*The EIP's created, will be assigned to the private subnets

```hcl
resource "aws_nat_gateway" "my_nat_gateway" {
  count          = 3
  allocation_id  = aws_eip.my_eip[count.index].id
  subnet_id      = aws_subnet.public_subnet[count.index].id
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```



