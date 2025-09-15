# Step 4: AWS CodeDeploy Setup

## 4.1 Create CodeDeploy Service Role

```bash
# Create trust policy for CodeDeploy
cat > codedeploy-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
    --role-name CodeDeployServiceRole \
    --assume-role-policy-document file://codedeploy-trust-policy.json

# Attach policy
aws iam attach-role-policy \
    --role-name CodeDeployServiceRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole
```

## 4.2 Create EC2 Instance Profile

```bash
# Create trust policy for EC2
cat > ec2-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create IAM role for EC2
aws iam create-role \
    --role-name CodeDeployEC2Role \
    --assume-role-policy-document file://ec2-trust-policy.json

# Attach policies
aws iam attach-role-policy \
    --role-name CodeDeployEC2Role \
    --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

aws iam attach-role-policy \
    --role-name CodeDeployEC2Role \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Create instance profile
aws iam create-instance-profile --instance-profile-name CodeDeployEC2Profile
aws iam add-role-to-instance-profile \
    --instance-profile-name CodeDeployEC2Profile \
    --role-name CodeDeployEC2Role
```

## 4.3 Launch EC2 Instances

```bash
# Launch EC2 instance with CodeDeploy agent
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --count 1 \
    --instance-type t3.micro \
    --key-name your-key-pair \
    --security-group-ids sg-12345678 \
    --subnet-id subnet-12345678 \
    --iam-instance-profile Name=CodeDeployEC2Profile \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyApp-Server},{Key=Environment,Value=Production}]' \
    --user-data file://ec2-userdata.sh
```

## 4.4 Create CodeDeploy Application

```bash
# Create application
aws deploy create-application \
    --application-name MyApp \
    --compute-platform Server

# Create deployment group
aws deploy create-deployment-group \
    --application-name MyApp \
    --deployment-group-name Production \
    --service-role-arn arn:aws:iam::ACCOUNT_ID:role/CodeDeployServiceRole \
    --ec2-tag-filters Key=Environment,Value=Production,Type=KEY_AND_VALUE
```

## Next Step
Proceed to Step 5: AWS CodePipeline Creation