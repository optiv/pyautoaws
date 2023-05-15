# pyautoaws
Simple Python wrapper for Terraform/Ansible to build AWS resources

## Usage

pyautoaws has two module options: 'build' or 'destroy'. Execution of the script will initiate terraform to provision the resources. The 'build' option executes both Terraform and an Ansible playbook to install common tools.

The ACCESS_KEY, SECRET_KEY, and MODULE flags are always required for both module types.

### Build

To build an EC2 instance or API Gateway, execute the script without the '--destroy (-d)' flag.

#### Module: ec2

Building an EC2 requires the REGION, NAME, INSTANCE_COUNT, KEY_NAME, and IP flags.

Example:
```
# python3 pytautoaws.py -i <aws_access_key> -s <aws_secret_key> -k <aws_key_pair> -m ec2 -r us-east-1 -ec 1 -n MyEC2 -ip x.x.x.x
```

#### Module: apigw

Building an API Gateway requires the REGION, NAME, API_URI flags.

Example:
```
# python3 pytautoaws.py -i <aws_access_key> -s <aws_secret_key> -m apigw -r us-east-1 -n MyAPI -u 'https://targetlogin.portal.com'
```

### Destroy

To destroy either provisioned EC2 resources or an API Gateway, execute the tool with the '--destroy (-d)' flag.

Example:
```
#python3 pyautoaws.py -i <aws_access_key> -s <aws_secret_key> -k <aws_key_pair> -m ec2 -d
```
### Help
```
# python3 pyautoaws.py -h
usage: pyautoaws.py [-h] -i ACCESS_KEY -s SECRET_KEY -k KEY_NAME [-r AWS_REGION] -m MODULE [-ec INSTANCE_COUNT] [-n NAME] [-ip IP]
                     [-u API_URI] [-d]

Simple Python wrapper for Terraform/Ansible to build AWS resources

options:
  -h, --help            show this help message and exit
  -i ACCESS_KEY, --aws-access-key-id ACCESS_KEY
                        AWS Access Key ID
  -s SECRET_KEY, --aws-secret-key SECRET_KEY
                        AWS Secret Access Key
  -k KEY_NAME, --aws-key-pair KEY_NAME
                        AWS SSH Key Pair name
  -r AWS_REGION, --region AWS_REGION
                        Specify AWS region (Ex: us-east-1, us-west-1)
  -m MODULE, --module MODULE
                        Specify module type (ec2 or apigw)
  -ec INSTANCE_COUNT, --ec2-count INSTANCE_COUNT
                        Number of EC2 instances to create
  -n NAME, --name NAME  Name tag to be assigned
  -ip IP, --public-ip IP
                        Your public IP for access
  -u API_URI, --uri API_URI
                        Target URI for API Gateway
  -d, --destroy         Destroy AWS resources
```
