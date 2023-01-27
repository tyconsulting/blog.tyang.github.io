---
title:
date: 2023-01-26 23:30
author: Tao Yang
permalink: /2023/01/26/using-azure-artifacts-as-python-pip-package-repository
summary:
categories:
  - Azure
tags:
  - Azure
  - Azure DevOps
---

In a recent engagement, we had to provision several Linux VMs in customer's Azure environment. The customer has blocked access to all public package repositories, including PyPI. We had to find a way to host our own Python packages in Azure so they can be installed on the VMs when required. Since Azure DevOps (ADO) is the CI/CD tool of choice for our project, Azure Artifacts became a logical choice because it's part of the Azure DevOps product suite.

We had initially manually download and install python pip on the Linux VM, and I have developed a solution to allow our DevOps engineers to upload Python pip packages into an Azure Artifacts feed on demand so it can be consumed by the Linux VM later.

The solution is consists of three parts:

1. An Azure Artifacts feed to host the Python pip packages
2. An Azure pipeline that can be triggered manually to add pip packages to the feed
3. Configure each Linux VM to use the Azure Artifacts feed as the pip package repository

I'll go through each part in detail.

## Azure Artifacts feed

I have created a new Azure DevOps project and an Azure Artifacts feed. In this demo, I have named the feed `pip-feed` in this case.

![1](../../../../assets/images/2023/01/pip-feed-01.jpg)

I have configured the feed as following:

 * Visibility: Member of your Azure Active Directory
 * Disabled Upstream sources
 * Scope: Organization (it doesn't matter if you choose the Project scope as long as the pipeline for uploading pip packages is in the same project)

For the feed permissions, I have given the `Project Collection Build Service (<your-ADO-organization>)` and `<your-ADO-project> Build Service (<your-ADO-Organization>)` contributor role. This is to allow the Azure pipelines to upload pip packages to the feed.

By default, Since I have created the feed, I have the Owner role assigned to the feed automatically. I have left the role assignment as it is because I am the one who will pull the packages from the feed on the Linux VM. However, Owner role is probably an overkill.

![2](../../../../assets/images/2023/01/pip-feed-02.jpg)

## Azure pipeline

I have created a YAML pipeline in my Azure DevOps project. The pipeline is configured to be triggered manually. When the pipeline is triggered, the user (our DevOps engineers) must specify the name of the pip package to be uploaded to the feed. The pipeline will download the pip package from PyPI and upload it to the Azure Artifacts feed.

![3](../../../../assets/images/2023/01/pip-feed-03.jpg)

The pipeline will also download all the dependencies from `pyPI.org` and upload them to the feed as well. This is to ensure that the Linux VM can install the pip package without any dependency issues. It will also ignore any existing package versions that are already stored in the Azure Artifacts feed.

![4](../../../../assets/images/2023/01/pip-feed-04.jpg)

The pipeline YAML file and the scripts used by the pipeline are available in my GitHub repo: [https://github.com/tyconsulting/azure.artifacts.demo](https://github.com/tyconsulting/azure.artifacts.demo)

The pipeline is created based on the YAML file [azure-pipeline-publish-pip-packages.yaml](https://github.com/tyconsulting/azure.artifacts.demo/blob/master/pipelines/azure-pipeline-publish-pip-packages.yaml)

To customize the YAML file for your own use, you need to change the `feedName` variable value on line 13.

![5](../../../../assets/images/2023/01/pip-feed-05.jpg)

## Configure Linux VM to use Azure Artifacts feed as pip package repository

The last step is to configure the Linux VM to use the Azure Artifacts feed as the pip package repository. This is done by adding the following lines to the `/etc/pip.conf` file (you can create this file if it doesn't exist using command `sudo touch /etc/pip.conf`):

```text
[global]
extra-index-url=https://pkgs.dev.azure.com/<organizationName>/_packaging/<feedName>/pypi/simple/
```

![6](../../../../assets/images/2023/01/pip-feed-06.jpg)

You can also find the connection details by clicking the `Connect to feed` button on the feed page.

![7](../../../../assets/images/2023/01/pip-feed-07.jpg)

Then click on `pip`

![8](../../../../assets/images/2023/01/pip-feed-08.jpg)

After the `pip.conf` file is updated, you can install the pip package from the Azure Artifacts feed using the `sudo pip install` command. In this case, I'll install the `azure-cli` package which was previously uploaded to the feed.

```bash
sudo pip install azure-cli
```

You should be prompted to enter user name and password for authenticating the the Azure Artifact feed. I have used my Azure AD account and a ADO Personal Access Token (PAT) as password. The PAT must have the `Read` permission on the feed.

![9](../../../../assets/images/2023/01/pip-feed-09.jpg)

I was prompted if I want to save the credential to keyring and if I selected yes, then I got a failed error message but the package installation went ahead anyway. I don't think it's a good idea to store the credential here anyway, so it's better that the credential is not stored.

![10](../../../../assets/images/2023/01/pip-feed-10.jpg)

After the package is installed, I was able to verify the Azure CLI package by running the `az` command.

![11](../../../../assets/images/2023/01/pip-feed-11.jpg)

## Conclusion

In this post, I have shown how I have built a self-service solution for hosting pip packages by only using Azure DevOps. I have to use whatever is available for us. There are many limitations for this approach, for example, unlike other commercial solutions, there is no vulnerability scanning capability for Azure Artifacts at the moment. If this is a requirement, you maybe able to built in into the pipeline to scan the downloaded package before uploading to the Azure Artifacts feed. However, this is not a trivial task. I have not tried it yet.

You can find more information from Microsoft's documentation [Get started with Python packages in Azure Artifacts](https://learn.microsoft.com/en-us/azure/devops/artifacts/quickstarts/python-packages?view=azure-devops)