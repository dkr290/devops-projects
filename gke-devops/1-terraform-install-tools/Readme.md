## Step-01: Introduction

1. Install gcloud CLI
2. Install Terraform CLI

# Install from the link

# Verify Python Version (Supported versions are Python 3 (3.5 to 3.11, 3.11 recommended)

```
python3 -V
mkdir  gcloud-cli-software
cd gcloud-cli-software
https://cloud.google.com/sdk/docs/install-sdk
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
ls -lrta
tar -zxf google-cloud-cli-linux-x86_64

# Run the install script with screen reader mode on:
./google-cloud-sdk/install.sh --screen-reader=true
```

# Open new terminal

AS PATH is updated, open new terminal

# gcloud cli version

gcloud version

### Step: gcloud CLI in local Terminal

```t
# Initialize gcloud CLI
gcloud init

# List accounts whose credentials are stored on the local system:
gcloud auth list

# List the properties in your active gcloud CLI configuration
gcloud config list

# View information about your gcloud CLI installation and the active configuration
gcloud info

# gcloud config Configurations Commands (For Reference)
gcloud config list
gcloud config configurations list
gcloud config configurations activate
gcloud config configurations create
gcloud config configurations delete
gcloud config configurations describe
gcloud config configurations rename
```

# install terraform in any method

# Copy terraform binary to /usr/local/bin

echo $PATH
mv terraform /usr/local/bin

## better to work with not default user account but create service principal for terraforem

Create a service account key:

1. Go to the IAM & Admin > Service Accounts page.
2. Click on the email address of your Terraform service account.
3. Go to the "Keys" tab.
4. Click "Add Key" and then "Create new key".
5. Select "JSON" as the key type and click "Create". This will download a JSON key file to your computer. Store this file securely.
   application Default Credentials (ADC) via gcloud (for local development):

If you are running Terraform locally and have the gcloud CLI installed, you can authenticate as the service account using the gcloud auth activate-service-account command:
Bash

gcloud auth activate-service-account YOUR_SERVICE_ACCOUNT_EMAIL --key-file="/path/to/your/service_account_key.json"

# for terraform to work

export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service_account_key.json
b.json

## GRANT PERMISSONS TO THE SERVICE ACCOUNT

1. gRANT IAM role eDITOR to your service account (terraform@project) using the Google Cloud Console:

2. Open the Google Cloud Console: Go to https://console.cloud.google.com/ and log in with your Google Cloud account.

3. Navigate to IAM & Admin: In the left-hand navigation menu, hover over "IAM & Admin" and then click on "IAM".

4. Select Your Project: Make sure the correct Google Cloud project (project1234) is selected at the top of the page.
   If not, click the project dropdown and choose the right one.

5. Find the Service Account: In the list of principals (users, groups, and service accounts), look for the row with your service account email: terraform@project.

6. If you don't see it listed, it might not have any roles assigned to it in this project yet. In that case, click the "+ GRANT ACCESS" button at the top of the page. In the "New principals" field, enter the service account email. Then, in the "Select a role" dropdown, search for and select the "Compute Network Admin" role and click "Save".
   Edit the Service Account's Permissions (If it's already listed):
