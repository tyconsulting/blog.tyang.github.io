---
id: 1708
title: EventID 28001 and 29112 on SCOM 2012 Management Server after Operational Database Move
date: 2013-01-25T21:58:57+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1708
permalink: /2013/01/25/eventid-28001-and-29112-on-scom-2012-management-server-after-operational-database-move/
categories:
  - SCOM
tags:
  - SCOM
  - SCOM Migration
---
Recently I’ve moved databases for my lab SCOM 2012 management group to a new SQL 2012 server as part of of my <a href="http://blog.tyang.org/2013/01/08/migrating-opsmgr-2012-rtm-to-opsmgr-2012-sp1/">RTM to SP1 migration</a>.

I followed the <a href="http://technet.microsoft.com/en-us/library/hh278848.aspx">How to Move the Operational Database guide</a> from TechNet. After the migration, I have noticed that on one of my management servers, I kept getting a warning event 28001 and an error event 29112 every couple of minutes in the OperationsManager event log.

<strong>Event 28001:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2013/01/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/01/image_thumb1.png" width="580" height="359" border="0" /></a>

<em><span style="color: #ff0000; font-size: small;">The Root connector received an exception from the Config Service on StateSyncRequest: </span></em>

<em><span style="color: #ff0000; font-size: small;">System.Runtime.Remoting.RemotingException: Failed to connect to an IPC Port: The system cannot find the file specified.
</span></em>

<em><span style="color: #ff0000; font-size: small;">Server stack trace:
at System.Runtime.Remoting.Channels.Ipc.IpcPort.Connect(String portName, Boolean secure, TokenImpersonationLevel impersonationLevel, Int32 timeout)
at System.Runtime.Remoting.Channels.Ipc.ConnectionCache.GetConnection(String portName, Boolean secure, TokenImpersonationLevel level, Int32 timeout)
at System.Runtime.Remoting.Channels.Ipc.IpcClientTransportSink.ProcessMessage(IMessage msg, ITransportHeaders requestHeaders, Stream requestStream, ITransportHeaders& responseHeaders, Stream& responseStream)
at System.Runtime.Remoting.Channels.BinaryClientFormatterSink.SyncProcessMessage(IMessage msg)</span></em>

<em><span style="color: #ff0000; font-size: small;">Exception rethrown at [0]:
at System.Runtime.Remoting.Proxies.RealProxy.HandleReturnMessage(IMessage reqMsg, IMessage retMsg)
at System.Runtime.Remoting.Proxies.RealProxy.PrivateInvoke(MessageData& msgData, Int32 type)
at Microsoft.EnterpriseManagement.Mom.Internal.IConfigService.OnStateSyncRequest(Guid source, UInt64 messageIdentifier, String cookie)</span></em>

<strong>Event 29112:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2013/01/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/01/image_thumb2.png" width="580" height="359" border="0" /></a>

<span style="color: #ff0000; font-size: small;"><em>OpsMgr Management Configuration Service failed to execute bootstrap work item 'ConfigurationStoreInitializeWorkItem' due to the following exception</em></span>

<span style="color: #ff0000; font-size: small;"><em>System.Data.SqlClient.SqlException (0x80131904): A network-related or instance-specific error occurred while establishing a connection to SQL Server. The server was not found or was not accessible. Verify that the instance name is correct and that SQL Server is configured to allow remote connections. (provider: Named Pipes Provider, error: 40 - Could not open a connection to SQL Server)
at System.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection)
at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning()
at System.Data.SqlClient.TdsParser.Connect(ServerInfo serverInfo, SqlInternalConnectionTds connHandler, Boolean ignoreSniOpenTimeout, Int64 timerExpire, Boolean encrypt, Boolean trustServerCert, Boolean integratedSecurity)
at System.Data.SqlClient.SqlInternalConnectionTds.AttemptOneLogin(ServerInfo serverInfo, String newPassword, Boolean ignoreSniOpenTimeout, TimeoutTimer timeout, SqlConnection owningObject)
at System.Data.SqlClient.SqlInternalConnectionTds.LoginNoFailover(ServerInfo serverInfo, String newPassword, Boolean redirectedUserInstance, SqlConnection owningObject, SqlConnectionString connectionOptions, TimeoutTimer timeout)
at System.Data.SqlClient.SqlInternalConnectionTds.OpenLoginEnlist(SqlConnection owningObject, TimeoutTimer timeout, SqlConnectionString connectionOptions, String newPassword, Boolean redirectedUserInstance)
at System.Data.SqlClient.SqlInternalConnectionTds..ctor(DbConnectionPoolIdentity identity, SqlConnectionString connectionOptions, Object providerInfo, String newPassword, SqlConnection owningObject, Boolean redirectedUserInstance)
at System.Data.SqlClient.SqlConnectionFactory.CreateConnection(DbConnectionOptions options, Object poolGroupProviderInfo, DbConnectionPool pool, DbConnection owningConnection)
at System.Data.ProviderBase.DbConnectionFactory.CreatePooledConnection(DbConnection owningConnection, DbConnectionPool pool, DbConnectionOptions options)
at System.Data.ProviderBase.DbConnectionPool.CreateObject(DbConnection owningObject)
at System.Data.ProviderBase.DbConnectionPool.UserCreateRequest(DbConnection owningObject)
at System.Data.ProviderBase.DbConnectionPool.GetConnection(DbConnection owningObject)
at System.Data.ProviderBase.DbConnectionFactory.GetConnection(DbConnection owningConnection)
at System.Data.ProviderBase.DbConnectionClosed.OpenConnection(DbConnection outerConnection, DbConnectionFactory connectionFactory)
at System.Data.SqlClient.SqlConnection.Open()
at Microsoft.EnterpriseManagement.ManagementConfiguration.DataAccessLayer.ConnectionManagementOperation.Execute()
at Microsoft.EnterpriseManagement.ManagementConfiguration.DataAccessLayer.DataAccessOperation.ExecuteSynchronously(Int32 timeoutSeconds, WaitHandle stopWaitHandle)
at Microsoft.EnterpriseManagement.ManagementConfiguration.SqlConfigurationStore.ConfigurationStore.ExecuteOperationSynchronously(IDataAccessConnectedOperation operation, String operationName)
at Microsoft.EnterpriseManagement.ManagementConfiguration.SqlConfigurationStore.ConfigurationStore.Initialize()
at Microsoft.EnterpriseManagement.ManagementConfiguration.Engine.ConfigurationStoreInitializeWorkItem.ExecuteWorkItem()</em></span>

This particular management server did not get rebuilt to Windows 2012, all other management servers I have in the MG has been completely rebuilt so they did not have this issue.

In the step 7 of the <a href="http://technet.microsoft.com/en-us/library/hh278848.aspx">guide from TechNet</a>, it mentioned updating the &lt;Category Name="Cmdb"&gt; tag in the <strong>%ProgramFiles%\System Center 2012\Operations Manager\Server\ConfigService.config</strong> file.

<a href="http://blog.tyang.org/wp-content/uploads/2013/01/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/01/image_thumb3.png" width="580" height="95" border="0" /></a>

However, the old DB server name also exists in the <strong>&lt;Category Name="ConfigStore"&gt;</strong> tag in the same file. this was not mentioned in the guide:

<a href="http://blog.tyang.org/wp-content/uploads/2013/01/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/01/image_thumb4.png" width="580" height="155" border="0" /></a>

After I updated &lt;Category Name="ConfigStore"&gt; section and restarted all the SCOM services on the management server, the error went away.