#!/bin/bash
#evtx2tln.sh converts Security.evtx from XML to TLN
# ~jsbrown
#
eventID_list=$"1100-The event logging service has shut down-\n
1101-Audit events have been dropped by the transport.-\n
1102-The audit log was cleared-\n
1104-The security Log is now full-\n
1105-Event log automatic backup-\n
1108-The event logging service encountered an error-\n
4608-Windows is starting up-\n
4609-Windows is shutting down-\n
4610-An authentication package has been loaded by the Local Security Authority-\n
4611-A trusted logon process has been registered with the Local Security Authority-\n
4612-Internal resources allocated for the queuing of audit messages have been exhausted, leading to the loss of some audits.-\n
4614-A notification package has been loaded by the Security Account Manager.-\n
4615-Invalid use of LPC port-\n
4616-The system time was changed.-\n
4618-A monitored security event pattern has occurred-\n
4621-Administrator recovered system from CrashOnAuditFail-\n
4622-A security package has been loaded by the Local Security Authority.-\n
4624-An account was successfully logged on-\n
4625-An account failed to log on-\n
4626-User/Device claims information-\n
4627-Group membership information.-\n
4634-An account was logged off-\n
4646-IKE DoS-prevention mode started-\n
4647-User initiated logoff-\n
4648-A logon was attempted using explicit credentials-\n
4649-A replay attack was detected-\n
4650-An IPsec Main Mode security association was established-\n
4651-An IPsec Main Mode security association was established-\n
4652-An IPsec Main Mode negotiation failed-\n
4653-An IPsec Main Mode negotiation failed-\n
4654-An IPsec Quick Mode negotiation failed-\n
4655-An IPsec Main Mode security association ended-\n
4656-A handle to an object was requested-\n
4657-A registry value was modified-\n
4658-The handle to an object was closed-\n
4659-A handle to an object was requested with intent to delete-\n
4660-An object was deleted-\n
4661-A handle to an object was requested-\n
4662-An operation was performed on an object-\n
4663-An attempt was made to access an object-\n
4664-An attempt was made to create a hard link-\n
4665-An attempt was made to create an application client context.-\n
4666-An application attempted an operation-\n
4667-An application client context was deleted-\n
4668-An application was initialized-\n
4670-Permissions on an object were changed-\n
4671-An application attempted to access a blocked ordinal through the TBS-\n
4672-Special privileges assigned to new logon-\n
4673-A privileged service was called-\n
4674-An operation was attempted on a privileged object-\n
4675-SIDs were filtered-\n
4688-A new process has been created-\n
4689-A process has exited-\n
4690-An attempt was made to duplicate a handle to an object-\n
4691-Indirect access to an object was requested-\n
4692-Backup of data protection master key was attempted-\n
4693-Recovery of data protection master key was attempted-\n
4694-Protection of auditable protected data was attempted-\n
4695-Unprotection of auditable protected data was attempted-\n
4696-A primary token was assigned to process-\n
4697-A service was installed in the system-\n
4698-A scheduled task was created-\n
4699-A scheduled task was deleted-\n
4700-A scheduled task was enabled-\n
4701-A scheduled task was disabled-\n
4702-A scheduled task was updated-\n
4703-A token right was adjusted-\n
4704-A user right was assigned-\n
4705-A user right was removed-\n
4706-A new trust was created to a domain-\n
4707-A trust to a domain was removed-\n
4709-IPsec Services was started-\n
4710-IPsec Services was disabled-\n
4711-PAStore Engine (1%)-\n
4712-IPsec Services encountered a potentially serious failure-\n
4713-Kerberos policy was changed-\n
4714-Encrypted data recovery policy was changed-\n
4715-The audit policy (SACL) on an object was changed-\n
4716-Trusted domain information was modified-\n
4717-System security access was granted to an account-\n
4718-System security access was removed from an account-\n
4719-System audit policy was changed-\n
4720-A user account was created-\n
4722-A user account was enabled-\n
4723-An attempt was made to change an account's password-\n
4724-An attempt was made to reset an accounts password-\n
4725-A user account was disabled-\n
4726-A user account was deleted-\n
4727-A security-enabled global group was created-\n
4728-A member was added to a security-enabled global group-\n
4729-A member was removed from a security-enabled global group-\n
4730-A security-enabled global group was deleted-\n
4731-A security-enabled local group was created-\n
4732-A member was added to a security-enabled local group-\n
4733-A member was removed from a security-enabled local group-\n
4734-A security-enabled local group was deleted-\n
4735-A security-enabled local group was changed-\n
4737-A security-enabled global group was changed-\n
4738-A user account was changed-\n
4739-Domain Policy was changed-\n
4740-A user account was locked out-\n
4741-A computer account was created-\n
4742-A computer account was changed-\n
4743-A computer account was deleted-\n
4744-A security-disabled local group was created-\n
4745-A security-disabled local group was changed-\n
4746-A member was added to a security-disabled local group-\n
4747-A member was removed from a security-disabled local group-\n
4748-A security-disabled local group was deleted-\n
4749-A security-disabled global group was created-\n
4750-A security-disabled global group was changed-\n
4751-A member was added to a security-disabled global group-\n
4752-A member was removed from a security-disabled global group-\n
4753-A security-disabled global group was deleted-\n
4754-A security-enabled universal group was created-\n
4755-A security-enabled universal group was changed-\n
4756-A member was added to a security-enabled universal group-\n
4757-A member was removed from a security-enabled universal group-\n
4758-A security-enabled universal group was deleted-\n
4759-A security-disabled universal group was created-\n
4760-A security-disabled universal group was changed-\n
4761-A member was added to a security-disabled universal group-\n
4762-A member was removed from a security-disabled universal group-\n
4763-A security-disabled universal group was deleted-\n
4764-A groups type was changed-\n
4765-SID History was added to an account-\n
4766-An attempt to add SID History to an account failed-\n
4767-A user account was unlocked-\n
4768-A Kerberos authentication ticket (TGT) was requested-\n
4769-A Kerberos service ticket was requested-\n
4770-A Kerberos service ticket was renewed-\n
4771-Kerberos pre-authentication failed-\n
4772-A Kerberos authentication ticket request failed-\n
4773-A Kerberos service ticket request failed-\n
4774-An account was mapped for logon-\n
4775-An account could not be mapped for logon-\n
4776-The domain controller attempted to validate the credentials for an account-\n
4777-The domain controller failed to validate the credentials for an account-\n
4778-A session was reconnected to a Window Station-\n
4779-A session was disconnected from a Window Station-\n
4780-The ACL was set on accounts which are members of administrators groups-\n
4781-The name of an account was changed-\n
4782-The password hash an account was accessed-\n
4783-A basic application group was created-\n
4784-A basic application group was changed-\n
4785-A member was added to a basic application group-\n
4786-A member was removed from a basic application group-\n
4787-A non-member was added to a basic application group-\n
4788-A non-member was removed from a basic application group..-\n
4789-A basic application group was deleted-\n
4790-An LDAP query group was created-\n
4791-A basic application group was changed-\n
4792-An LDAP query group was deleted-\n
4793-The Password Policy Checking API was called-\n
4794-An attempt was made to set the Directory Services Restore Mode administrator password-\n
4797-An attempt was made to query the existence of a blank password for an account-\n
4798-A user's local group membership was enumerated.-\n
4799-A security-enabled local group membership was enumerated-\n
4800-The workstation was locked-\n
4801-The workstation was unlocked-\n
4802-The screen saver was invoked-\n
4803-The screen saver was dismissed-\n
4816-RPC detected an integrity violation while decrypting an incoming message-\n
4817-Auditing settings on object were changed.-\n
4818-Proposed Central Access Policy does not grant the same access permissions as the current Central Access Policy-\n
4819-Central Access Policies on the machine have been changed-\n
4820-A Kerberos Ticket-granting-ticket (TGT) was denied because the device does not meet the access control restrictions-\n
4821-A Kerberos service ticket was denied because the user, device, or both does not meet the access control restrictions-\n
4822-NTLM authentication failed because the account was a member of the Protected User group-\n
4823-NTLM authentication failed because access control restrictions are required-\n
4824-Kerberos preauthentication by using DES or RC4 failed because the account was a member of the Protected User group-\n
4825-A user was denied the access to Remote Desktop. By default, users are allowed to connect only if they are members of the Remote Desktop Users group or Administrators group-\n
4826-Boot Configuration Data loaded-\n
4830-SID History was removed from an account-\n
4864-A namespace collision was detected-\n
4865-A trusted forest information entry was added-\n
4866-A trusted forest information entry was removed-\n
4867-A trusted forest information entry was modified-\n
4868-The certificate manager denied a pending certificate request-\n
4869-Certificate Services received a resubmitted certificate request-\n
4870-Certificate Services revoked a certificate-\n
4871-Certificate Services received a request to publish the certificate revocation list (CRL)-\n
4872-Certificate Services published the certificate revocation list (CRL)-\n
4873-A certificate request extension changed-\n
4874-One or more certificate request attributes changed.-\n
4875-Certificate Services received a request to shut down-\n
4876-Certificate Services backup started-\n
4877-Certificate Services backup completed-\n
4878-Certificate Services restore started-\n
4879-Certificate Services restore completed-\n
4880-Certificate Services started-\n
4881-Certificate Services stopped-\n
4882-The security permissions for Certificate Services changed-\n
4883-Certificate Services retrieved an archived key-\n
4884-Certificate Services imported a certificate into its database-\n
4885-The audit filter for Certificate Services changed-\n
4886-Certificate Services received a certificate request-\n
4887-Certificate Services approved a certificate request and issued a certificate-\n
4888-Certificate Services denied a certificate request-\n
4889-Certificate Services set the status of a certificate request to pending-\n
4890-The certificate manager settings for Certificate Services changed.-\n
4891-A configuration entry changed in Certificate Services-\n
4892-A property of Certificate Services changed-\n
4893-Certificate Services archived a key-\n
4894-Certificate Services imported and archived a key-\n
4895-Certificate Services published the CA certificate to Active Directory Domain Services-\n
4896-One or more rows have been deleted from the certificate database-\n
4897-Role separation enabled-\n
4898-Certificate Services loaded a template-\n
4899-A Certificate Services template was updated-\n
4900-Certificate Services template security was updated-\n
4902-The Per-user audit policy table was created-\n
4904-An attempt was made to register a security event source-\n
4905-An attempt was made to unregister a security event source-\n
4906-The CrashOnAuditFail value has changed-\n
4907-Auditing settings on object were changed-\n
4908-Special Groups Logon table modified-\n
4909-The local policy settings for the TBS were changed-\n
4910-The group policy settings for the TBS were changed-\n
4911-Resource attributes of the object were changed-\n
4912-Per User Audit Policy was changed-\n
4913-Central Access Policy on the object was changed-\n
4928-An Active Directory replica source naming context was established-\n
4929-An Active Directory replica source naming context was removed-\n
4930-An Active Directory replica source naming context was modified-\n
4931-An Active Directory replica destination naming context was modified-\n
4932-Synchronization of a replica of an Active Directory naming context has begun-\n
4933-Synchronization of a replica of an Active Directory naming context has ended-\n
4934-Attributes of an Active Directory object were replicated-\n
4935-Replication failure begins-\n
4936-Replication failure ends-\n
4937-A lingering object was removed from a replica-\n
4944-The following policy was active when the Windows Firewall started-\n
4945-A rule was listed when the Windows Firewall started-\n
4946-A change has been made to Windows Firewall exception list. A rule was added-\n
4947-A change has been made to Windows Firewall exception list. A rule was modified-\n
4948-A change has been made to Windows Firewall exception list. A rule was deleted-\n
4949-Windows Firewall settings were restored to the default values-\n
4950-A Windows Firewall setting has changed-\n
4951-A rule has been ignored because its major version number was not recognized by Windows Firewall-\n
4952-Parts of a rule have been ignored because its minor version number was not recognized by Windows Firewall-\n
4953-A rule has been ignored by Windows Firewall because it could not parse the rule-\n
4954-Windows Firewall Group Policy settings has changed. The new settings have been applied-\n
4956-Windows Firewall has changed the active profile-\n
4957-Windows Firewall did not apply the following rule-\n
4958-Windows Firewall did not apply the following rule because the rule referred to items not configured on this computer-\n
4960-IPsec dropped an inbound packet that failed an integrity check-\n
4961-IPsec dropped an inbound packet that failed a replay check-\n
4962-IPsec dropped an inbound packet that failed a replay check-\n
4963-IPsec dropped an inbound clear text packet that should have been secured-\n
4964-Special groups have been assigned to a new logon-\n
4965-IPsec received a packet from a remote computer with an incorrect Security Parameter Index (SPI).-\n
4976-During Main Mode negotiation, IPsec received an invalid negotiation packet.-\n
4977-During Quick Mode negotiation, IPsec received an invalid negotiation packet.-\n
4978-During Extended Mode negotiation, IPsec received an invalid negotiation packet.-\n
4979-IPsec Main Mode and Extended Mode security associations were established.-\n
4980-IPsec Main Mode and Extended Mode security associations were established-\n
4981-IPsec Main Mode and Extended Mode security associations were established-\n
4982-IPsec Main Mode and Extended Mode security associations were established-\n
4983-An IPsec Extended Mode negotiation failed-\n
4984-An IPsec Extended Mode negotiation failed-\n
4985-The state of a transaction has changed-\n
5024-The Windows Firewall Service has started successfully-\n
5025-The Windows Firewall Service has been stopped-\n
5027-The Windows Firewall Service was unable to retrieve the security policy from the local storage-\n
5028-The Windows Firewall Service was unable to parse the new security policy.-\n
5029-The Windows Firewall Service failed to initialize the driver-\n
5030-The Windows Firewall Service failed to start-\n
5031-The Windows Firewall Service blocked an application from accepting incoming connections on the network.-\n
5032-Windows Firewall was unable to notify the user that it blocked an application from accepting incoming connections on the network-\n
5033-The Windows Firewall Driver has started successfully-\n
5034-The Windows Firewall Driver has been stopped-\n
5035-The Windows Firewall Driver failed to start-\n
5037-The Windows Firewall Driver detected critical runtime error. Terminating-\n
5038-Code integrity determined that the image hash of a file is not valid-\n
5039-A registry key was virtualized.-\n
5040-A change has been made to IPsec settings. An Authentication Set was added.-\n
5041-A change has been made to IPsec settings. An Authentication Set was modified-\n
5042-A change has been made to IPsec settings. An Authentication Set was deleted-\n
5043-A change has been made to IPsec settings. A Connection Security Rule was added-\n
5044-A change has been made to IPsec settings. A Connection Security Rule was modified-\n
5045-A change has been made to IPsec settings. A Connection Security Rule was deleted-\n
5046-A change has been made to IPsec settings. A Crypto Set was added-\n
5047-A change has been made to IPsec settings. A Crypto Set was modified-\n
5048-A change has been made to IPsec settings. A Crypto Set was deleted-\n
5049-An IPsec Security Association was deleted-\n
5050-An attempt to programmatically disable the Windows Firewall using a call to INetFwProfile.FirewallEnabled(FALSE-\n
5051-A file was virtualized-\n
5056-A cryptographic self test was performed-\n
5057-A cryptographic primitive operation failed-\n
5058-Key file operation-\n
5059-Key migration operation-\n
5060-Verification operation failed-\n
5061-Cryptographic operation-\n
5062-A kernel-mode cryptographic self test was performed-\n
5063-A cryptographic provider operation was attempted-\n
5064-A cryptographic context operation was attempted-\n
5065-A cryptographic context modification was attempted-\n
5066-A cryptographic function operation was attempted-\n
5067-A cryptographic function modification was attempted-\n
5068-A cryptographic function provider operation was attempted-\n
5069-A cryptographic function property operation was attempted-\n
5070-A cryptographic function property operation was attempted-\n
5071-Key access denied by Microsoft key distribution service-\n
5120-OCSP Responder Service Started-\n
5121-OCSP Responder Service Stopped-\n
5122-A Configuration entry changed in the OCSP Responder Service-\n
5123-A configuration entry changed in the OCSP Responder Service-\n
5124-A security setting was updated on OCSP Responder Service-\n
5125-A request was submitted to OCSP Responder Service-\n
5126-Signing Certificate was automatically updated by the OCSP Responder Service-\n
5127-The OCSP Revocation Provider successfully updated the revocation information-\n
5136-A directory service object was modified-\n
5137-A directory service object was created-\n
5138-A directory service object was undeleted-\n
5139-A directory service object was moved-\n
5140-A network share object was accessed-\n
5141-A directory service object was deleted-\n
5142-A network share object was added.-\n
5143-A network share object was modified-\n
5144-A network share object was deleted.-\n
5145-A network share object was checked to see whether client can be granted desired access-\n
5146-The Windows Filtering Platform has blocked a packet-\n
5147-A more restrictive Windows Filtering Platform filter has blocked a packet-\n
5148-The Windows Filtering Platform has detected a DoS attack and entered a defensive mode; packets associated with this attack will be discarded.-\n
5149-The DoS attack has subsided and normal processing is being resumed.-\n
5150-The Windows Filtering Platform has blocked a packet.-\n
5151-A more restrictive Windows Filtering Platform filter has blocked a packet.-\n
5152-The Windows Filtering Platform blocked a packet-\n
5153-A more restrictive Windows Filtering Platform filter has blocked a packet-\n
5154-The Windows Filtering Platform has permitted an application or service to listen on a port for incoming connections-\n
5155-The Windows Filtering Platform has blocked an application or service from listening on a port for incoming connections-\n
5156-The Windows Filtering Platform has allowed a connection-\n
5157-The Windows Filtering Platform has blocked a connection-\n
5158-The Windows Filtering Platform has permitted a bind to a local port-\n
5159-The Windows Filtering Platform has blocked a bind to a local port-\n
5168-Spn check for SMB/SMB2 fails.-\n
5169-A directory service object was modified-\n
5170-A directory service object was modified during a background cleanup task-\n
5376-Credential Manager credentials were backed up-\n
5377-Credential Manager credentials were restored from a backup-\n
5378-The requested credentials delegation was disallowed by policy-\n
5440-The following callout was present when the Windows Filtering Platform Base Filtering Engine started-\n
5441-The following filter was present when the Windows Filtering Platform Base Filtering Engine started-\n
5442-The following provider was present when the Windows Filtering Platform Base Filtering Engine started-\n
5443-The following provider context was present when the Windows Filtering Platform Base Filtering Engine started-\n
5444-The following sub-layer was present when the Windows Filtering Platform Base Filtering Engine started-\n
5446-A Windows Filtering Platform callout has been changed-\n
5447-A Windows Filtering Platform filter has been changed-\n
5448-A Windows Filtering Platform provider has been changed-\n
5449-A Windows Filtering Platform provider context has been changed-\n
5450-A Windows Filtering Platform sub-layer has been changed-\n
5451-An IPsec Quick Mode security association was established-\n
5452-An IPsec Quick Mode security association ended-\n
5453-An IPsec negotiation with a remote computer failed because the IKE and AuthIP IPsec Keying Modules (IKEEXT) service is not started-\n
5456-PAStore Engine applied Active Directory storage IPsec policy on the computer-\n
5457-PAStore Engine failed to apply Active Directory storage IPsec policy on the computer-\n
5458-PAStore Engine applied locally cached copy of Active Directory storage IPsec policy on the computer-\n
5459-PAStore Engine failed to apply locally cached copy of Active Directory storage IPsec policy on the computer-\n
5460-PAStore Engine applied local registry storage IPsec policy on the computer-\n
5461-PAStore Engine failed to apply local registry storage IPsec policy on the computer-\n
5462-PAStore Engine failed to apply some rules of the active IPsec policy on the computer-\n
5463-PAStore Engine polled for changes to the active IPsec policy and detected no changes-\n
5464-PAStore Engine polled for changes to the active IPsec policy, detected changes, and applied them to IPsec Services-\n
5465-PAStore Engine received a control for forced reloading of IPsec policy and processed the control successfully-\n
5466-PAStore Engine polled for changes to the Active Directory IPsec policy, determined that Active Directory cannot be reached, and will use the cached copy of the Active Directory IPsec policy instead-\n
5467-PAStore Engine polled for changes to the Active Directory IPsec policy, determined that Active Directory can be reached, and found no changes to the policy-\n
5468-PAStore Engine polled for changes to the Active Directory IPsec policy, determined that Active Directory can be reached, found changes to the policy, and applied those changes-\n
5471-PAStore Engine loaded local storage IPsec policy on the computer-\n
5472-PAStore Engine failed to load local storage IPsec policy on the computer-\n
5473-PAStore Engine loaded directory storage IPsec policy on the computer-\n
5474-PAStore Engine failed to load directory storage IPsec policy on the computer-\n
5477-PAStore Engine failed to add quick mode filter-\n
5478-IPsec Services has started successfully-\n
5479-IPsec Services has been shut down successfully-\n
5480-IPsec Services failed to get the complete list of network interfaces on the computer-\n
5483-IPsec Services failed to initialize RPC server. IPsec Services could not be started-\n
5484-IPsec Services has experienced a critical failure and has been shut down-\n
5485-IPsec Services failed to process some IPsec filters on a plug-and-play event for network interfaces-\n
5632-A request was made to authenticate to a wireless network-\n
5633-A request was made to authenticate to a wired network-\n
5712-A Remote Procedure Call (RPC) was attempted-\n
5888-An object in the COM+ Catalog was modified-\n
5889-An object was deleted from the COM+ Catalog-\n
5890-An object was added to the COM+ Catalog-\n
6144-Security policy in the group policy objects has been applied successfully-\n
6145-One or more errors occured while processing security policy in the group policy objects-\n
6272-Network Policy Server granted access to a user-\n
6273-Network Policy Server denied access to a user-\n
6274-Network Policy Server discarded the request for a user-\n
6275-Network Policy Server discarded the accounting request for a user-\n
6276-Network Policy Server quarantined a user-\n
6277-Network Policy Server granted access to a user but put it on probation because the host did not meet the defined health policy-\n
6278-Network Policy Server granted full access to a user because the host met the defined health policy-\n
6279-Network Policy Server locked the user account due to repeated failed authentication attempts-\n
6280-Network Policy Server unlocked the user account-\n
6281-Code Integrity determined that the page hashes of an image file are not valid...-\n
6400-BranchCache: Received an incorrectly formatted response while discovering availability of content.-\n
6401-BranchCache: Received invalid data from a peer. Data discarded.-\n
6402-BranchCache: The message to the hosted cache offering it data is incorrectly formatted.-\n
6403-BranchCache: The hosted cache sent an incorrectly formatted response to the client's message to offer it data.-\n
6404-BranchCache: Hosted cache could not be authenticated using the provisioned SSL certificate.-\n
6405-BranchCache: %2 instance(s) of event id %1 occurred.-\n
6406-%1 registered to Windows Firewall to control filtering for the following:-\n
6407-%1-\n
6408-Registered product %1 failed and Windows Firewall is now controlling the filtering for %2.-\n
6409-BranchCache: A service connection point object could not be parsed-\n
6410-Code integrity determined that a file does not meet the security requirements to load into a process. This could be due to the use of shared sections or other issues-\n
6416-A new external device was recognized by the system.-\n
6417-The FIPS mode crypto selftests succeeded-\n
6418-The FIPS mode crypto selftests failed-\n
6419-A request was made to disable a device-\n
6420-A device was disabled-\n
6421-A request was made to enable a device-\n
6422-A device was enabled-\n
6423-The installation of this device is forbidden by system policy-\n
6424-The installation of this device was allowed, after having previously been forbidden by policy-\n
8191-Highest System-Defined Audit Message Value-\n"

#Use evtexport or dumpevtx.py to convert evtx file to XML
clear
echo "Evtx2tln extracts Windows EVTX files to TLN format" 
echo ""
echo "Usage: evtx2tln.sh [file]" 
echo ""
[ "$1" == "" ] && echo "Fail!  try again..."  && exit
[ ! -f "$1" ] && [ ! -d "$1" ] && echo "Fail! try again..." && exit

echo "Please wait....." 
echo "Creating file named Security.evtx.xml file(s)" 

# Use evtexport if file is not already in xml
#[ -f "$1" ] && evtxexport -f xml $1|tee -a Security.evtx.xml
#[ -f "$1" ] && evtxexport -f xml $1|awk '{printf $0}'|sed 's/\s//g'|sed 's/<\/Event>/<\/Event>\n/g' |tee -a Flat.txt

cat $1| while read line; do
Time=$(echo $line |grep -Po '(?<=SystemTime\=\").{3,35}(?=\"\/)') 
EvtxID=$(echo $line |grep -Po '(?<=<EventID>)[0-9]*(?=<\/EventID)')
[ "$Time" != "" ] && printf $Time
[ "$Time" != "" ] && printf "|extx|||"
[ "$EvtxID" != "" ] &&  echo -e $eventID_list | grep $EvtxID
done
