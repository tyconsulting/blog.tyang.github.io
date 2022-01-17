---
title: Azure SQL Virtual Machines - Sharing My Code and Experience
date: 2022-01-13 16:00
author: Tao Yang
permalink: /2022/01/13/azure-sql-vm
summary: Sharing my template and experience for Azure SQL Virtual Machines
categories:
  - Azure
tags:
  - Azure
  - Azure Bicep
  - Azure SQL VM
---

## Background

As we all know, Azure SQL is considered as a product family that consists of 3 distinct products:

* Azure SQL server (PaaS)
* Azure SQL Managed Instance (PaaS)
* Azure SQL Virtual Machine (IaaS)

Over the last few years, I have spent A LOT of my time on deploying and configuring Azure SQL Virtual Machines in both clustered and standalone configurations. I have written code in both Terraform and ARM templates coupled with Azure DevOps YAML pipelines for Azure SQL VMs in multiple engagements. Along the way I have seen many issues and mistakes made by myself and my colleagues. Since I haven't really seen too many good resources on Azure SQL VMs out there, I thought I'd share some of my experience and code with the community.

Around 18 months ago I have developed a Terraform module for standalone Azure SQL VMs for a customer. At that time, due to some limitations in the Terraform AzureRM provider, The TF module I developed used an ARM template under the hood (instead of using the native Azure SQL VM resource in the AzureRM TF provider which is now more feature complete). At that time, creating SQL Always-On Availability Group(AOAG) in a clustered environment required some manual configurations (for creating the AOAG). Since then Microsoft has introduced new capability that AOAG can now be created together with its listener using ARM.

Few months ago I was involved in developing a YAML Azure DevOps pipeline to deploy Azure SQL VM clusters using ARM templates.

I started working on the code that I'm sharing in this blog post before Christmas. After few solid days of effort, I have developed an Azure Bicep template with various supporting modules based on the code I had previously.

## Bicep Template

The code is located on my BlogPost GitHub repo. You can find it **[HERE](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/sql.vm)**.

The instructions on how to use the Bicep template is documented in the BlogPost GitHub repo already, including how to configure the template parameters, commands to deploy the templates using Azure CLI. It also provided 2 sample parameter files for deploying standalone and clustered SQL VMs. You can use as the way it is, or incorporate it into your CI/CD pipelines.

From a high-level view, the following Azure SQL VM feature have been baked into the template:

* Domain join for the VM
* Disk configuration (SQL data, log and tempdb drives)
* SQL server SKU and license type
* Configuring Azure SQL VM Automated Backup (using Azure Storage Account blob storage)
* Configuring Azure Key Vault integration (SQL EKM provider for Azure Key Vault) - used by SQL TDE
* Optionally enable R Services
* SQL Cluster and Always-On Availability Group using a witness storage account (blog storage)

The following features have not been implemented at this stage:

* File Share witness for SQL cluster - This is a fairly new capability, I have not used it yet and due to time constraint, it's not implemented in the template at this stage
* SQL server Automated Patching - I never had requirements to implement it, so it's been disabled in the template.

The bicep template **[main.bicep](https://github.com/tyconsulting/BlogPosts/blob/master/Azure-Bicep/sql.vm/main.bicep)** leverage a number of modules in the [modules](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/sql.vm/modules) folder for various components that make up the SQL VM and AOAG cluster:

* **[sql-vm.bicep](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/sql.vm/modules/sql-vm.bicep)**: Bicep module for creating Azure Virtual Machine as we as Azure SQL VM ("Microsoft.SqlVirtualMachine/SqlVirtualMachines") resources. The SQL VM can be standalone or as a cluster node.
* **[sql-group.bicep](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/sql.vm/modules/sql-group.bicep)**: Bicep module for creating Azure SQL VM Groups (SQL VM Group represents the Windows Server Failover Cluster)
* **[sql-listener.bicep](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/sql.vm/modules/sql-listener.bicep)**: Bicep module for Azure SQL VM Availability Group listener and load balancer
* **[storage-account.bicep](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/sql.vm/modules/sql-listener.bicep)**: Bicep module for Azure Storage Account (used to create storage accounts used for cluster witness and SQL auto backup)
* **[sql-cluster.join.bicep](https://github.com/tyconsulting/BlogPosts/tree/master/Azure-Bicep/sql.vm/modules/sql-listener.bicep)**: Bicep module for joining *existing* SQL VMs to a cluster (not used in the Bicep template)

Since modules are converted to nested deployments in ARM template, when this template is deployed, multiple ARM deployments are created (depending on the parameter configuration):

*AOAG Cluster:*

![1](../../../../assets/images/2022/01/azure-sql-vm-01.jpg)

*Standalone SQL VM:*

![2](../../../../assets/images/2022/01/azure-sql-vm-02.jpg)

## Post Deployment Configuration (Limitations)

Although we can now deploy a fully functional SQL cluster with AOAG, there are still many manual configurations required after the template deployment. The following is what I can think of right now based on my past experience:

**Configuring additional disk drives**

The Azure SQL VM resource provider can only create logical drives for SQL data, log and tempdb drives. These drives are based on Windows Storage Pools. If there are additional drives need to be created on SQL VMs, they will need to be created outside of code for Azure SQL VMs. i.e. A customer did not use the Automated Backup capability and wanted to use the traditional way - using SQL server agent jobs to backup databases to a local disk first. In their environment, I had to develop a separate process of creating the backup drive using the [VM Run Command](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/run-command) capability in Terraform.

**SQL service account folder permissions**

The service account for SQL DB instances does not require local administrator rights. When creating a SQL cluster, the SQL service account must be a domain account. At the time of writing this article, this account does not have NTFS permissions to the SQL data, log and tempdb folders. This can potentially be a problem when you try to move system databases to the data and log folders because by default system DBs are located on C:. One of my customers had a requirement to move system DBs to the default SQL data and log folders. I had to develop a separate process to grant SQL service account NTFS permissions to these folders.

**The "Perform Volume Maintenance Tasks" right for SQL service account**

As we all know it's best practice that the SQL service account should be granted "Perform volume maintenance tasks" right to improve the performance when databases are created and expanded. At the time of writing this article, by default, this right is not granted to the service account you specified in the template. It must be granted separately (either via local policy or a domain GPO).

**SQL Server Collation**

The Azure SQL VM resource provider does not provide capability to specify the SQL server collation when the resource is created. Often the customer will need to change the server collation. This is done by re-running the SQL server installation. Based on my past experience, as the result of re-running SQL server installation, the 2 required sql logins used by the Azure SQL VM resource are removed after re ran SQL installation. This will make the SQL VM to an unmanaged state. Fortunately the problem and fix is documented on [this TechNet article](https://social.technet.microsoft.com/wiki/contents/articles/52483.sql-server-on-azure-vm-troubleshooting-can-t-access-the-sql-server-configuration-page-from-the-portal.aspx). So make sure recreate these 2 sql logins after changing the SQL server collation.

**Temp DB file count**

As SQL best practice, many DBAs would configure the temp DB to use multiple data files based on the number of CPU cores on the SQL server. At the time of writing this article, the number of temp DB files are left as default. It needs to be configured manually if this is a requirement.

**SQL memory allocation**

Many organizations configure the miminum and maximum memory that the SQL DB instance can use. This is not configured as part of the template. If this is a requirement, it needs to be configured manually.

**Max Degree of Parallelism (MDOP)**

At the time of writing this article, MDOP needs to be configured manually.

**Always-On Availability Group**

When user databases are created, they need to be manually added to the AOAG created by the template. After adding a user database to the AOAG, it should show up as green (as shown below):

![3](../../../../assets/images/2022/01/azure-sql-vm-03.jpg)

**Transparent Data Encryption (TDE)**

Unlike Azure SQL PaaS servers where TDE can be enabled when the database is created. For SQL VMs, only the Azure Key Vault EKM provider can be enabled via template code. It does not automatically enable TDE on any databases that are created after the SQL VMs are created. TDE must be manually configured for each individual database of your choice.

**Long Term Backup**

The Automated Backup capability provided by Azure SQL VM can only be store the backup for maximum 30 days. If long term backup is required, this capability may not be an ideal solution. Alternatively, Azure Backup supports SQL VMs. It could be a better solution. More information can be found [HERE](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/backup-restore#azbackup)

**Removing not required SQL components**

By default, all SQL components (DB engine, SSIS, SSAS, SSRS) are all installed in the marketplace Azure SQL VM image (i'm taking about Windows servers only). A customer of mine had requirements to uninstall components that are not required from the SQL VMs. If this is a requirement, it needs to be done manually.

**SQL Logins**

By default, the SQL instance is configured to use Mixed authentication mode. If you need to change it Windows Only mode, it needs to be done manually. Also, you need to manually create addtional required SQL logins. By default, only the sql admin (if you specified it in the template) and the Windows local administrators have sysadmin rights in the DB instance.

## Other Considerations

During my previous engagements, I have participated in many discussions with engineers, DBAs and architects around Azure SQL VM configurations and also had to re-work and update many previously deployed environments. There were so many times that I was banging my head against the wall when working on Azure SQL VM. There are things that I wish I knew in the beginning so my life could be less miserable.

**Azure Key Vault Integration (EKM)**

If there is a requirement that the database also needs to be hosted outside of Azure (i.e. other public cloud on on-prem), using Azure Key Vault for TDE may not be the best option. This is because the encryption key is created within Azure Key Vault, you cannot export the private key from KV if the key is created within the KV. One of my customers decided to use certificates for TDE and abandoned this feature.

**Disk size and performance**

As the size increases, Azure Premium data disks can be very expensive. I have experienced many cases that the data disks on SQL VMs need to be re-sized due to the size and performance requirements. It is very painful if you need to add additional disks to SQL VMs (especially via code), because of the following factors:

1. The data, log and tempDB drives created by the Azure SQL VM resource provider are based on Windows Server Storage Pools. A dedicated pool is created for each drive. When you add additional drives to an existing pool, you cannot change the column count of the pool because it can only be set at the creation time. For example, if you start with 2 data disks for SQL data drive and later on add 2 additional disks, the performance will not be as good as having 4 data disks to begin with.

2. Maximum number of data disks are bound to the VM SKU limit. Often when you try to add additional disks, you also had to change the VM SKU

3. Drives cannot be extended via code when the SQL VMs are clustered. The Azure SQL VM resource provider does not support extending clustered VMs. Although it can be done within Windows (by adding additional disks, extending the pool, and logical drives manully). It is very convoluted process, maybe I will cover it in another post.

![4](../../../../assets/images/2022/01/azure-sql-vm-04.jpg)

4. Difficult to implement via Terraform. To add additional disks to SQL VMs via code, you must create an Azure SQL VM resource with disk configuration type set to "EXTEND" (Reference: [ARM/Bicep](https://docs.microsoft.com/en-us/azure/templates/microsoft.sqlvirtualmachine/sqlvirtualmachines?tabs=bicep#storageconfigurationsettings), [Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_machine#disk_type)). If you are updating the existing Terraform code that you used to intially create the SQL VM resource, you will get an error when executing the TF code because the resource name for the disk extension is the same as the initial SQL VM. In Terraform you cannot define 2 resources with the same name. When I developed the SQL VM disk extension Terraform module for a customer, I had to wrap an ARM template within Terraform to work around this issue. Again, it's a convoluted process.

If you ask me what is the number 1 advice I can give based on my past experience, I'd say pay special attention to the disk size and performance requirements and be generous when sizing the disks. Also pay attention to the tempdb IOPS requirements, don't just look at the disk size. For premium data disks, the size and IOPS are tied together in different SKUs - the bigger the disk is, the higher the IOPS allowance is assigned. Premium disks are charged by the tier you choose. You wont get a discount if you specify a smaller size for a tier. So there is no point to use custom sizes for these disks. Always go for the maximum size that the tier supports.

It is also recommended to enable ReadOnly host caching for the Azure data disks that are used for SQL data and temp DB drives.

It's recommended to set the [storageWorkloadType](https://docs.microsoft.com/en-us/azure/templates/microsoft.sqlvirtualmachine/sqlvirtualmachines?tabs=bicep#storageconfigurationsettings) to *OLTP* for SQL servers hosting none Data Warehouse workload. By setting this parameter to OLTP, the disk drives are formatted to 64k block size, which is optimized for hosting SQL data files. I had requirements where this was not set correctly initially, and it is painful to change it because it involves re-formatting the drives since there is no native way to change it in Windows without re-formatting the drive.

**Azure Availability Zones**

When creating SQL VM clusters, consider placing cluster nodes in different Availability Zones in the Azure region. This capability is already coded in the Bicep template I shared, it automatically spread the VMs into different availability zones.

**Windows Firewall configuration**

If Windows Firewall is in use, make sure all required SQL ports (i.e. 1433 for DB engine, 443 for SSRS and 59999 for AOAG, etc) are allowed in the Windows firewall rules. This can be overlooked when troubleshooting connectivity issues if you only focus on the Azure aspect (NSGs, Azure Firewall, etc.)

**Enable SQL Assessments for SQL VM solution**

[SQL Assessments](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-assessment-for-sql-vm) is a solution within Azure Log Analytics. If you are using Log Analytics and have VMs report to it, consider enable this solution.

**Named DB instance**

Azure SQL VM only supports 1 DB engine instance per VM and it is the default instance (MSSQLServer).

## Troubleshooting Tips

**Ext_SqlIaaSExtensionError: Error: 'Healthy'**

![5](../../../../assets/images/2022/01/azure-sql-vm-05.png)

I have seen this error returned from the ARM deployment many times. Although I have raised with ARM Product Team and they forwarded to the SQL team many months ago, I have received no feedback or acknowledgement so far. It is still happening to me yesterday. However I believe I know the cause of this issue and managed to fix it.

This error can occur when you update an existing Azure SQL VM where Azure Key Vault integration is enabled. When AKV integration is enabled, a credential object is created in SQL using the service principal provided in the template. When the Azure SQL VM object (essentially the SQL IaaS VM extension) is removed, this credential object is not removed in SQL. When the SQL VM resource is being installed again when this obsolete credential object still exists in SQL, you will receive this "Healthy" error. The fix is easy: delete the credential object and rerun the template:

find the credential:

```sql
USE master
select * from sys.credentials
```

![6](../../../../assets/images/2022/01/azure-sql-vm-06.jpg)

if there is a credential with the same name as what's defined in the template (in my case, I'm using *sysadmin_ekm_cred* as it's the default value in my template), delete it using the SQL command below (replace [credential_name]):

```sql
USE master
drop credential [credential_name]
```

After the credential is deleted, re-run your template and it should be OK.

## Conclusion

Consider this post as my brain dump for anything Azure SQL VM related. It's based on my past experience.  I hope you find the Bicep template, as well as the brain dump useful.

I honestly think it is difficult to implement Azure SQL VMs to say the least. I hope things I have shared here would help you and make your life easier when dealing with Azure SQL VMs.

## References

* ARM / Bicep Documentation
    * [SQL VM](https://docs.microsoft.com/en-us/azure/templates/microsoft.sqlvirtualmachine/sqlvirtualmachines?tabs=bicep)
    * [SQL VM Group](https://docs.microsoft.com/en-us/azure/templates/microsoft.sqlvirtualmachine/sqlvirtualmachinegroups?tabs=bicep)
    * [Availability Group Listener](https://docs.microsoft.com/en-us/azure/templates/microsoft.sqlvirtualmachine/sqlvirtualmachinegroups/availabilitygrouplisteners?tabs=bicep)

* [Quickstart template for creating AoAG for existing SQL VMs](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.sqlvirtualmachine/sql-vm-aglistener-setup) - I used this as a starting point for the SQL listener component of my bicep template. thanks to the contributors of this template.
