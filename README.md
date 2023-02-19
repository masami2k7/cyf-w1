# cyf-w1 explanation
## Context
The following exercise is given to the users, there is no requirement to use infrastructure as code as thats not yet been taught as part of the curriculum, this repo was to prove this exercise can be done completely with infrastructure as code using AWS and Terraform.
```
  - Create an Ubuntu VM on one of the main cloud providers. If you have no preference, go with AWS.
  - You must be able to access your VM remotely via SSH
  - Create a 2nd user that can also access the VM with a separate credential.
  - Use cowsay :cow: to set a welcome back message for the users every time they log into the server.
  Bonus Points:
    - Secure your VM access so that it can only be accessed from your home (hint: IPs, security groups)
    - Setup anything useful on the server that you can showcase to the class.
  **Important notes: :rotating_light: :rotating_light:
  - When setting up your cloud account, make sure you configure the MFA security right away.
  - When launching resources, make sure you are have chosen the 'free-tier' ones.
  - Keep an eye on the billing monitor. Configure billing alerts! No one should spend a single pound on these assignments (edited) 
```

## Pre-Requisites

### Software Required
* Install brew (see link below for brew)
* brew Install Git
* brew Install Terraform
* brew Install AWS CLI

### AWS Connectivity (for Terraform to talk to AWS)

Either

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY
```

or (via AWS CLI)

```
aws configure
```

### AWS Account Setup

Manually create a key pair in aws called "cyf-w1" and save the pem file locally (this happens automatically into your downloads).

Move your pemfile somewhere convenient and update to be secured using command "chmod 400 cyf-w1.pem"

### Configuring your SSH Key for GitHub (if your new to github and need to commit changes)
In order to be able to interact with Github to checkin / out files its recommend to setup ssh keys as follows
```
ssh-keygen -t ed25519 -C "your email address"
eval "$(ssh-agent -s)"
ls -al ~/.ssh  
touch ~/.ssh/config 
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub
  
ssh -T git@github.com   
# Attempts to ssh to GitHub
```
You will now be able to check out this repo from Github using your SSH key
```
git clone git@github.com:<username>/<repo-name>.git
```
But in order to commit changes back for a new GIT setup you will need to configure the followingå
```
git config --global user.email "<emailaddress>"
git config --global user.name "<username>"
```

## Running the application

### Initialise your local variables
Firstly, you will need to create a local file with your security information and the VPC ID where the instance will be deployed. Create file named terrafor.tfvars with the following entries
```
cyf-vpc-id   = {VPD-ID} /* The VPC ID for the appropriate region should be here */
cyf-localIP  = {LOCAL-IP}  /* Your Local IP Must go here */
cyf-public-key = {SSH-PUBLIC-KEY} /* Should be something like "ssh-rsa {long-string-of-text}" instructions below on how to get this"
```
To get your SSH public key run the following command where your pem file from AWS has been saved
```
ssh keygen -y -f "pemfile.pem" 
```

### Run the commands in this order

terraform init

terraform fmt

terraform apply

The terraform outputs file configuration provides easy access via copy and paste to get the AWS instance public DNS, something like this
```
aws_instance.app_server: Still creating... [30s elapsed]
aws_instance.app_server: Creation complete after 32s [id=i-027ec0151c60d55e2]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

instance_dns = "ec2-<IPADDRESS>.eu-west-2.compute.amazonaws.com"
```
You can copy the output and put into either of the following commands to connect into the server
```
ssh -v -i "<PEMFILE>" freddy@<INSTANCE_DNS>
ssh -v -i "<PEMFILE>" ubuntu@<INSTANCE_DNS>
```
Afterwhich you should see something like this
```
Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

 ______________
< hello freddy >
 --------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
Thats it, your done!  :)
## Useful Links
### Pre-requisites

Installing stuff via Brew

https://brew.sh

Connecting to GitHub using SSH

https://docs.github.com/en/authentication/connecting-to-github-with-ssh 

Configuring the AWS ClI for your credentials

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

### Main Task

Finding the Ubuntu AMI ID for your Region

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html

AWS Creating Key Pairs

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html#having-ec2-create-your-key-pair 

Adding additional users to an Amazon linux instance (the manual way)

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-users.html

Using Cloud-Init via User Data Cloud Config to create multiple users

https://aws.amazon.com/premiumsupport/knowledge-center/ec2-user-account-cloud-init-user-data/

Cloud Init Documentation for Understanding the supported commands, used this for package installs and run command.

https://cloudinit.readthedocs.io/en/latest/index.html


## Lessons Learned 
* The Terraform default instance will use the defauly security group and default VPC, but that doesnt allow SSH by default! 
* User Data is awkward, attempted to use terraform EOF syntax inline in the main.tf, all looked ok but seems there was some issue, probably white space so moved to a seperate file.
* It's not obvious how to pipe an environment variable key into a file, but cna be done with ''.
* Enviromnent export commands arent persisted between reboots, so the Terraform default guidance from terraform learn doesnt work the next time you resume your work.
* There are lots of ways listed to run a command on login, only the one in this example seems to work for all users (regardless of when they are added), using the profile.d
* Terraform .12 included some changes to how you can use the template functions / files to use variables for the user data example in this repo.
* Creating users via bash in user data is a minefield, I established a sequence of commands from one of the links above, but it was not happy running those as bash in user data so further reseach took me to the cloud init solution you can find in this example.