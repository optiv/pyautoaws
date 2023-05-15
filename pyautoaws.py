import argparse
import subprocess
import os

# Define the command line arguments
parser = argparse.ArgumentParser(description='Simple Python wrapper for Terraform/Ansible to build AWS resources')
parser.add_argument('-i', '--aws-access-key-id', required=True, dest='access_key', type=str, help='AWS Access Key ID')
parser.add_argument('-s', '--aws-secret-key', required=True, dest='secret_key', type=str, help='AWS Secret Access Key')
parser.add_argument('-k', '--aws-key-pair', required=False, dest='key_name', type=str, help='AWS SSH Key Pair name')
parser.add_argument('-r', '--region', dest='aws_region', type=str, help='Specify AWS region (Ex: us-east-1, us-west-1)')
parser.add_argument('-m', '--module', required=True, dest='module', type=str, help='Specify module type (ec2 or apigw)')
parser.add_argument('-ec', '--ec2-count', required=False, dest='instance_count', type=int, help='Number of EC2 instances to create')
parser.add_argument('-n', '--name', dest='name', type=str, help='Name tag to be assigned')
parser.add_argument('-ip', '--public-ip', dest='ip', type=str, help='Your public IP for access')
parser.add_argument('-u', '--uri', dest='api_uri', type=str, help='Target URI for API Gateway')
parser.add_argument('-d', '--destroy', dest='destroy', action='store_true', help='Destroy AWS resources')

# Parse the command line arguments
args = parser.parse_args()

# Check for ssh key_name if ec2 is requested
if args.module == 'ec2' and args.key_name is None:
    parser.error('-k/--aws-key-pair is required when the "ec2" module type is specified.')

# terraform command definition
terraform_command = ['terraform', 'apply', '-auto-approve']

# Change directory to the module directory
os.chdir(args.module)

# Run the Terraform command
if args.destroy == False:
    print("\nYou chose to build!\n")
    if args.module == "ec2":
        print("Provisioning requested EC2:")
        # initialize terraform
        subprocess.run(['terraform', 'init'], check=True)
        # apply terraform configuration to build resources
        subprocess.run(['terraform', 'apply', '-auto-approve', f'-var=aws_access_key={args.access_key}', f'-var=aws_secret_key={args.secret_key}', f'-var=aws_key_name={args.key_name}', f'-var=aws_region={args.aws_region}', f'-var=instance_count={args.instance_count}', f'-var=name={args.name}', f'-var=ip={args.ip}'], check=True)
    elif args.module == "apigw":
        print("Provisioning requested API Gateway:")
        # initialize terraform
        subprocess.run(['terraform', 'init'], check=True)
        # apply terraform configuration to build resources
        subprocess.run(['terraform', 'apply', '-auto-approve', f'-var=aws_access_key={args.access_key}', f'-var=aws_secret_key={args.secret_key}', f'-var=aws_key_name={args.key_name}', f'-var=aws_region={args.aws_region}', f'-var=api_uri={args.api_uri}', f'-var=name={args.name}'], check=True)
else:
    print("\nYou chose to destroy!\n")
    if args.module == "ec2":
        print("Deprovisioning EC2 resource(s):\n")
        subprocess.run(['terraform', 'destroy', '-auto-approve', f'-var=aws_access_key={args.access_key}', f'-var=aws_secret_key={args.secret_key}', f'-var=aws_key_name={args.key_name}', "-var-file=project_vars.tfvars", ], check=True)
    elif args.module == "apigw":
        print("Deprovisioning API Gateway resource:\n")
        subprocess.run(['terraform', 'destroy', '-auto-approve', f'-var=aws_access_key={args.access_key}', f'-var=aws_secret_key={args.secret_key}', f'-var=aws_key_name={args.key_name}', "-var-file=project_vars.tfvars", ], check=True)
