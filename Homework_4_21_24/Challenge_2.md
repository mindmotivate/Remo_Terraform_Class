###  AWSTemplateFormatVersion: '2010-09-09'
###  Description: 'AWS infrastructure deployment with VPC, subnets, NAT gateway, load balancer, and autoscaling group.'


### Resources Section:

###  VPC (Virtual Private Cloud) and Subnets:
Creates a VPC with specified CIDR block and enables DNS support and hostnames.
```yaml
Resources:
  AppVPC:
    Type: 'AWS::EC2::VPC'
    Properties:
      CidrBlock: '10.32.0.0/16'
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: 'Name'
          Value: 'app1'
        - Key: 'Service'
          Value: 'application1'
        - Key: 'Owner'
          Value: 'Chewbacca'
        - Key: 'Planet'
          Value: 'Mustafar'
```
### Defines three public subnets across different availability zones.
```yaml
  PublicSubnetOne:
    Type: 'AWS::EC2::Subnet'
    Properties:
      VpcId: !Ref AppVPC
      CidrBlock: '10.32.1.0/24'
      AvailabilityZone: 'us-east-1a'
      MapPublicIpOnLaunch: true
      Tags:
        - Key: 'Name'
          Value: 'public-subnet-1'

  PublicSubnetTwo:
    Type: 'AWS::EC2::Subnet'
    Properties:
      VpcId: !Ref AppVPC
      CidrBlock: '10.32.2.0/24'
      AvailabilityZone: 'us-east-1b'
      MapPublicIpOnLaunch: true
      Tags:
        - Key: 'Name'
          Value: 'public-subnet-2'

  PublicSubnetThree:
    Type: 'AWS::EC2::Subnet'
    Properties:
      VpcId: !Ref AppVPC
      CidrBlock: '10.32.3.0/24'
      AvailabilityZone: 'us-east-1c'
      MapPublicIpOnLaunch: true
      Tags:
        - Key: 'Name'
          Value: 'public-subnet-3'
```
### Defines three private subnets across the same availability zones.
```yaml
PrivateSubnetOne:
    Type: 'AWS::EC2::Subnet'
    Properties:
      VpcId: !Ref AppVPC
      CidrBlock: '10.32.11.0/24'
      AvailabilityZone: 'us-east-1a'
      MapPublicIpOnLaunch: false
      Tags:
        - Key: 'Name'
          Value: 'private-subnet-1'

  PrivateSubnetTwo:
    Type: 'AWS::EC2::Subnet'
    Properties:
      VpcId: !Ref AppVPC
      CidrBlock: '10.32.12.0/24'
      AvailabilityZone: 'us-east-1b'
      MapPublicIpOnLaunch: false
      Tags:
        - Key: 'Name'
          Value: 'private-subnet-2'

  PrivateSubnetThree:
    Type: 'AWS::EC2::Subnet'
    Properties:
      VpcId: !Ref AppVPC
      CidrBlock: '10.32.13.0/24'
      AvailabilityZone: 'us-east-1c'
      MapPublicIpOnLaunch: false
      Tags:
        - Key: 'Name'
          Value: 'private-subnet-3'
```
### Internet Gateway:
Attaches an Internet Gateway to the VPC to enable internet access.
```yaml
  InternetGateway:
    Type: 'AWS::EC2::InternetGateway'
    Properties:
      Tags:
        - Key: 'Name'
          Value: 'app1_igw'

  GatewayAttachment:
    Type: 'AWS::EC2::VPCGatewayAttachment'
    Properties:
      VpcId: !Ref AppVPC
      InternetGatewayId: !Ref InternetGateway
```
### NAT Gateway:
Sets up a NAT Gateway in one of the public subnets for instances in private subnets to access the internet.
```yaml
  NatEIP:
    Type: 'AWS::EC2::EIP'
    Properties:
      Domain: 'vpc'

  NatGateway:
    Type: 'AWS::EC2::NatGateway'
    Properties:
      AllocationId: !GetAtt NatEIP.AllocationId
      SubnetId: !Ref PublicSubnetOne
      Tags:
        - Key: 'Name'
          Value: 'app1_nat'
```
### Route Tables:
Defines separate route tables for public and private subnets.
Associates the public route table with public subnets to route internet-bound traffic through the Internet Gateway.
Associates the private route table with private subnets to route traffic through the NAT Gateway.
```yaml
  PublicRouteTable:
    Type: 'AWS::EC2::RouteTable'
    Properties:
      VpcId: !Ref AppVPC
      Tags:
        - Key: 'Name'
          Value: 'public'

  PublicRoute:
    Type: 'AWS::EC2::Route'
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: '0.0.0.0/0'
      GatewayId: !Ref InternetGateway

  PublicSubnetRouteTableAssociationOne:
    Type: 'AWS::EC2::SubnetRouteTableAssociation'
    Properties:
      SubnetId: !Ref PublicSubnetOne
      RouteTableId: !Ref PublicRouteTable

  PublicSubnetRouteTableAssociationTwo:
    Type: 'AWS::EC2::SubnetRouteTableAssociation'
    Properties:
      SubnetId: !Ref PublicSubnetTwo
      RouteTableId: !Ref PublicRouteTable

  PublicSubnetRouteTableAssociationThree:
    Type: 'AWS::EC2::SubnetRouteTableAssociation'
    Properties:
      SubnetId: !Ref PublicSubnetThree
      RouteTableId: !Ref PublicRouteTable

  PrivateRouteTable:
    Type: 'AWS::EC2::RouteTable'
    Properties:
      VpcId: !Ref AppVPC
      Tags:
        - Key: 'Name'
          Value: 'private'

  PrivateRoute:
    Type: 'AWS::EC2::Route'
    Properties:
      RouteTableId: !Ref PrivateRouteTable
      DestinationCidrBlock: '0.0.0.0/0'
      NatGatewayId: !Ref NatGateway

  PrivateSubnetRouteTableAssociationOne:
    Type: 'AWS::EC2::SubnetRouteTableAssociation'
    Properties:
      SubnetId: !Ref PrivateSubnetOne
      RouteTableId: !Ref PrivateRouteTable

  PrivateSubnetRouteTableAssociationTwo:
    Type: 'AWS::EC2::SubnetRouteTableAssociation'
    Properties:
      SubnetId: !Ref PrivateSubnetTwo
      RouteTableId: !Ref PrivateRouteTable

  PrivateSubnetRouteTableAssociationThree:
    Type: 'AWS::EC2::SubnetRouteTableAssociation'
    Properties:
      SubnetId: !Ref PrivateSubnetThree
      RouteTableId: !Ref PrivateRouteTable
```
### Security Group:
Creates a security group for servers allowing HTTP and SSH traffic.
```yaml
  SecurityGroupServers:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      GroupDescription: 'Security group for servers'
      VpcId: !Ref AppVPC
      SecurityGroupIngress:
        - IpProtocol: 'tcp'
          FromPort: 80
          ToPort: 80
          CidrIp: '0.0.0.0/0'
          Description: 'Allow HTTP traffic'
        - IpProtocol: "tcp"
          FromPort: 22
          ToPort: 22
          CidrIp: "0.0.0.0/0"
          Description: 'Allow SSH traffic'
```
### Load Balancer:
Sets up an Application Load Balancer (ALB) across the public subnets with the specified security group.
```yaml
  LoadBalancer:
    Type: 'AWS::ElasticLoadBalancingV2::LoadBalancer'
    Properties:
      Subnets:
        - !Ref PublicSubnetOne
        - !Ref PublicSubnetTwo
        - !Ref PublicSubnetThree
      SecurityGroups:
        - !Ref SecurityGroupServers
      Type: 'application'
      Tags:
        - Key: 'Name'
          Value: 'App1LoadBalancer'
```
# Target Group:
Defines a target group for the ALB to route traffic to instances.
```yaml
  TargetGroup:
    Type: 'AWS::ElasticLoadBalancingV2::TargetGroup'
    Properties:
      VpcId: !Ref AppVPC
      Port: 80
      Protocol: 'HTTP'
      HealthCheckEnabled: true
      HealthCheckPath: '/'
      HealthCheckProtocol: 'HTTP'
      HealthCheckIntervalSeconds: 30
      HealthCheckTimeoutSeconds: 5
      HealthyThresholdCount: 5
      UnhealthyThresholdCount: 2
      Matcher:
        HttpCode: '200'
      TargetType: 'instance'
      Tags:
        - Key: 'Name'
          Value: 'App1TargetGroup'
```
### Listener:
Configures a listener on the ALB to forward traffic to the target group.
  ```yaml
  Listener:
    Type: 'AWS::ElasticLoadBalancingV2::Listener'
    Properties:
      LoadBalancerArn: !Ref LoadBalancer
      Protocol: 'HTTP'
      Port: 80
      DefaultActions:
        - Type: 'forward'
          TargetGroupArn: !Ref TargetGroup
```
### Auto Scaling Group:
Sets up an Auto Scaling Group with a launch template.
Specifies desired capacity, minimum and maximum size, health check type, and associated target group.
 ```yaml 
  AutoScalingGroup:
    Type: 'AWS::AutoScaling::AutoScalingGroup'
    Properties:
      LaunchTemplate:
        LaunchTemplateId: !Ref LaunchTemplate
        Version: !GetAtt LaunchTemplate.LatestVersionNumber
      MinSize: '3'
      MaxSize: '15'
      DesiredCapacity: '6'
      VPCZoneIdentifier: [!Ref PrivateSubnetOne, !Ref PrivateSubnetTwo, !Ref PrivateSubnetThree]
      TargetGroupARNs: [!Ref TargetGroup]
      HealthCheckType: 'ELB'
      HealthCheckGracePeriod: 300
      Tags:
        - Key: 'Name'
          PropagateAtLaunch: true
          Value: 'app1-instance'
```
### Launch Template:
Configures a launch template with user data to bootstrap instances.
Installs Apache HTTP server and generates HTML content displaying EC2 instance details.
Includes metadata retrieval using the EC2 instance metadata service.
```yaml  
  LaunchTemplate:
    Type: 'AWS::EC2::LaunchTemplate'
    Properties:
      LaunchTemplateData:
        ImageId: 'ami-0f1a6835595fb9246'
        InstanceType: 't2.micro'
        KeyName: 'secure_shell'
        SecurityGroupIds:
          - !Ref SecurityGroupServers
        UserData:
          Fn::Base64: !Sub |
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
            # Fetch and store metadata
            TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
            LOCAL_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
            AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
            MAC_ADDRESS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/mac)
            VPC_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC_ADDRESS/vpc-id)
            # Generate the HTML content
            cat <<EOF > /var/www/html/index.html
            <!doctype html>
            <html lang="en" class="h-100">
            <head>
            <title>EC2 Instance Details</title>
            </head>
            <body>
            <div>
            <h1>Instance Details</h1>
            <p><strong>Instance Name:</strong> $(hostname -f)</p>
            <p><strong>Instance Private IP Address:</strong> $LOCAL_IPV4</p>
            <p><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</p>
            <p><strong>Virtual Private Cloud (VPC):</strong> $VPC_ID</p>
            </div>
            <div id="gif-container">
              <img id="gif" src="https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExNjhvYnFqb3V0ZDBxMzBzZWRwZDVubXBnNXExZHV2YzY0Nm9vZzdpMiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/2xyA2MtdS3nJigFaMa/giphy.gif" alt="GCP Single Region Load Balancer">
            </div>
            </body>
            </html>
            EOF
```
### Outputs Section:
Provides outputs for the Load Balancer DNS name, DynamoDB table name, and CloudWatch alarm ARN for reference or usage outside the template.
```yaml
Outputs:
  LoadBalancerDNSName:
    Description: 'DNS Name of the Load Balancer'
    Value: !GetAtt LoadBalancer.DNSName

  DynamoDBTableName:
    Description: 'Name of the DynamoDB table'
    Value: !Ref DynamoDBTable

  CloudWatchAlarmARN:
    Description: ARN of the CloudWatch alarm for high CPU utilization
    Value: !Ref HighCPUUtilizationAlarm
```

### AWS CLI Commands:

```bash
aws cloudformation validate-template --template-body file://dynamo_db.yaml
 
aws cloudformation create-stack --stack-name my-dynamodb-stack --template-body file://dynamo_db.yaml --capabilities CAPABILITY_IAM

aws cloudformation describe-stacks --stack-name my-dynamodb-stack

aws cloudformation delete-stack --stack-name my-dynamodb-stack
```

### Terminal Results:

```bash
{
    "Parameters": [],
    "Description": "AWS infrastructure deployment with VPC, subnets, NAT gateway, load balancer, and autoscaling group."
}

{
    "StackId": "arn:aws:cloudformation:us-east-1:732504928444:stack/my-dynamodb-stack/205dcfc0-fe03-11ee-a0c2-0eab19c9c72b"
}


{
    "Stacks": [
        {
            "StackId": "arn:aws:cloudformation:us-east-1:732504928444:stack/my-dynamodb-stack/205dcfc0-fe03-11ee-a0c2-0eab19c9c72b",
            "StackName": "my-dynamodb-stack",
            "Description": "AWS infrastructure deployment with VPC, subnets, NAT gateway, load balancer, and autoscaling group.",
            "CreationTime": "2024-04-19T04:13:07.718000+00:00",
            "RollbackConfiguration": {},
            "StackStatus": "CREATE_IN_PROGRESS",
            "DisableRollback": false,
            "NotificationARNs": [],
            "Capabilities": [
                "CAPABILITY_IAM"
            ],
            "Tags": [],
            "EnableTerminationProtection": false,
            "DriftInformation": {
                "StackDriftStatus": "NOT_CHECKED"
            }
        }
    ]
}

```

```bash
            "Outputs": [
                {
                    "OutputKey": "LoadBalancerDNSName",
                    "OutputValue": "my-dyn-LoadB-VWj4BzlD4siO-1628621587.us-east-1.elb.amazonaws.com",
                    "Description": "DNS Name of the Load Balancer"
                },
                {
                    "OutputKey": "DynamoDBTableName",
                    "OutputValue": "MyDynamoDBTable",
                    "Description": "Name of the DynamoDB table"
                },
                {
                    "OutputKey": "CloudWatchAlarmARN",
                    "OutputValue": "HighCPUUtilization",
                    "Description": "ARN of the CloudWatch alarm for high CPU utilization"
```

### Console Results:

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/f78bc0c0-6b96-43d3-b7c4-6a9d451a52b4)

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/cbef8900-b4d3-4ffe-9deb-886d1f3e3ffe)

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/6c9b079a-11b5-46f5-a20c-0cd3c20dc4b8)

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/8334fa45-de74-457d-a8c1-342744ed4a08)

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/942fb9be-1eac-4f12-984e-cab8aaee6f75)

![image](https://github.com/mindmotivate/Remo_Terraform_Class/assets/130941970/59737c3f-dfd4-4986-a705-6b64b065b7f0)

