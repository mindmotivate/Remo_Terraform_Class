AWSTemplateFormatVersion: '2010-09-09'
Description: 'AWS infrastructure deployment with VPC, subnets, NAT gateway, load balancer, and autoscaling group.'



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
Internet Gateway:
Attaches an Internet Gateway to the VPC to enable internet access.
yaml
Copy code
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
NAT Gateway:
Sets up a NAT Gateway in one of the public subnets for instances in private subnets to access the internet.
yaml
Copy code
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
Route Tables:
Defines separate route tables for public and private subnets.
Associates the public route table with public subnets to route internet-bound traffic through the Internet Gateway.
Associates the private route table with private subnets to route traffic through the NAT Gateway.
yaml
Copy code
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
Security Group:
Creates a security group for servers allowing HTTP and SSH traffic.
yaml
Copy code
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
Load Balancer:
Sets up an Application Load Balancer (ALB) across the public subnets with the specified security group.
yaml
Copy code
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
Target Group:
Defines a target group for the ALB to route traffic to instances.
yaml
Copy code
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
Listener:
Configures a listener on the ALB to forward traffic to the target group.
yaml
Copy code
  Listener:
    Type: 'AWS::ElasticLoadBalancingV2::Listener'
    Properties:
      LoadBalancerArn: !Ref LoadBalancer
      Protocol: 'HTTP'
      Port: 80
      DefaultActions:
        - Type: 'forward'
          TargetGroupArn: !Ref TargetGroup
Auto Scaling Group:
Sets up an Auto Scaling Group with a launch template.
yaml
Copy code
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
Launch Template:
Configures a launch template with user data to bootstrap instances.
yaml
Copy code
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
DynamoDB Table:
Creates a DynamoDB table with a specified name and attributes.
yaml
Copy code
  DynamoDBTable:
    Type: 'AWS::DynamoDB::Table'
    Properties:
      TableName: 'MyDynamoDBTable'
      AttributeDefinitions:
        - AttributeName: 'id'
          AttributeType: 'S'
      KeySchema:
        - AttributeName: 'id'
          KeyType: 'HASH'
      BillingMode: PAY_PER_REQUEST
      Tags:
        - Key: 'Name'
          Value: 'MyDynamoDBTable'
SNS Topic:
Creates an SNS topic with a display name and topic name.
yaml
Copy code
  MySNSTopic:
    Type: 'AWS::SNS::Topic'
    Properties:
      DisplayName: 'MySNSTopic'
      TopicName: 'MySNSTopic'
CloudWatch Alarm:
Sets up a CloudWatch alarm to monitor high CPU utilization of instances in the Auto Scaling Group.
yaml
Copy code
  HighCPUUtilizationAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: HighCPUUtilization
      ComparisonOperator: GreaterThanThreshold
      EvaluationPeriods: 5
      MetricName: CPUUtilization
      Namespace: AWS/EC2
      Period: 300
      Statistic: Average
      Threshold: 75
      AlarmActions:
        - !Ref MySNSTopic
      Dimensions:
        - Name: AutoScalingGroupName
          Value: !Ref AutoScalingGroup # Replace with your AutoScaling group name or ARN
Outputs Section:
yaml
Copy code
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
