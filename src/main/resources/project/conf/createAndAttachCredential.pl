##########################
# createAndAttachCredential.pl
##########################

use ElectricCommander;

use constant {
	SUCCESS => 0,
	ERROR   => 1,
};

my $ec = new ElectricCommander();
$ec->abortOnError(0);

my $credName = "$[/myJob/config]";
my $xpath = $ec->getFullCredential("credential");
my $userName = $xpath->findvalue("//userName");
my $password = $xpath->findvalue("//password");

# Create credential
my $projName = "@PLUGIN_KEY@-@PLUGIN_VERSION@";

$ec->deleteCredential($projName, $credName);
$xpath = $ec->createCredential($projName, $credName, $userName, $password);
my $errors = $ec->checkAllErrors($xpath);

# Give config the credential's real name
my $configPath = "/projects/$projName/weblogic_cfgs/$credName";
$xpath = $ec->setProperty($configPath . "/credential", $credName);
$errors .= $ec->checkAllErrors($xpath);

# Give job launcher full permissions on the credential
my $user = "$[/myJob/launchedByUser]";
$xpath = $ec->createAclEntry("user", $user,
    {projectName => $projName,
     credentialName => $credName,
     readPrivilege => allow,
     modifyPrivilege => allow,
     executePrivilege => allow,
     changePermissionsPrivilege => allow});
$errors .= $ec->checkAllErrors($xpath);

# Attach credential to steps that will need it
$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'StartAdminServer',
     stepName => 'StartAdminServer'});
$errors .= $ec->checkAllErrors($xpath);

$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'StartManagedServer',
     stepName => 'StartInstance'});
$errors .= $ec->checkAllErrors($xpath);

$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'StopManagedServer',
     stepName => 'StopInstance'});
$errors .= $ec->checkAllErrors($xpath);

$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'StopAdminServer',
     stepName => 'StopAdminServer'});
$errors .= $ec->checkAllErrors($xpath);


$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'CheckServerStatus',
     stepName => 'CheckServerStatus'});
$errors .= $ec->checkAllErrors($xpath);

$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'RunDeployer',
     stepName => 'RunJob'});
$errors .= $ec->checkAllErrors($xpath);

$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'RunWLST',
     stepName => 'RunWLST'});
$errors .= $ec->checkAllErrors($xpath);

$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'StartApp',
     stepName => 'StartApp'});
$errors .= $ec->checkAllErrors($xpath);

$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'StopApp',
     stepName => 'StopApp'});
$errors .= $ec->checkAllErrors($xpath);

$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'DeployApp',
     stepName => 'DeployApp'});
$errors .= $ec->checkAllErrors($xpath);

$xpath = $ec->attachCredential($projName, $credName,
    {procedureName => 'UndeployApp',
     stepName => 'UndeployApp'});
$errors .= $ec->checkAllErrors($xpath);

if ($errors ne '') {
    
    # Cleanup the partially created configuration we just created
    $ec->deleteProperty($configPath);
    $ec->deleteCredential($projName, $credName);
    my $errMsg = 'Error creating configuration credential: ' . $errors;
    $ec->setProperty("/myJob/configError", $errMsg);
    print $errMsg;
    exit ERROR;
    
}