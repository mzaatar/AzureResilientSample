param (
    [Parameter(Mandatory=$True)]
	[ValidateSet("Sydney","Melbourne","both")]
	[string]$mode,
	[Parameter(Mandatory=$false)]
	[ValidateSet($true,$false)]
	[bool]$AllowDataLoss = $false #pass true for unplanned failover, and by default it is false to run planend failover
)
# --------------------------- Functions ---------------------------

function InitiatePlannedDbFailover([string]$dbName, [string]$Rg, [string]$ServerName, [string]$PartnerRg, [bool]$AllowDataLoss)
{
    $SqlDB = Get-AzureRmSqlDatabase -DatabaseName $dbName -ResourceGroupName $Rg -ServerName $ServerName
	$isSecondary = IsSecondarySqlDatabase -SqlDB $SqlDB
	if($isSecondary -eq  $true)
	{
		Write-Output "Switching database $dbName in server $ServerName to take the primary role in Geo-Replication"
		if($AllowDataLoss -eq $true) #non-planned failover, Azure outage etc
		{
			Set-AzureRmSqlDatabaseSecondary -ResourceGroupName $SqlDB.ResourceGroupName -ServerName $SqlDB.ServerName -DatabaseName $SqlDB.databaseName -PartnerResourceGroupName $PartnerRg -Failover -AllowDataLoss
		}
		elseif($AllowDataLoss -eq $false) #Planned failover
		{
			Set-AzureRmSqlDatabaseSecondary -ResourceGroupName $SqlDB.ResourceGroupName -ServerName $SqlDB.ServerName -DatabaseName $SqlDB.databaseName -PartnerResourceGroupName $PartnerRg -Failover
		}
	}
	elseif($isSecondary -eq  $false)
	{
		Write-Warning "The database $dbName in server $ServerName is already a primary db so db failover won't run"
	}
}

function IsSecondarySqlDatabase 
{
    # This function determines whether specified database is performing a secondary replication role
    param
    (
        [Microsoft.Azure.Commands.Sql.Database.Model.AzureSqlDatabaseModel] $SqlDB
    )
    process {
        $IsSecondary = $false;
        $ReplicationLinks = Get-AzureRmSqlDatabaseReplicationLink `
            -ResourceGroupName $SqlDB.ResourceGroupName `
            -ServerName $SqlDB.ServerName `
            -DatabaseName $SqlDB.DatabaseName `
            -PartnerResourceGroupName $SqlDB.ResourceGroupName
        $ReplicationLinks | ForEach-Object -Process `
        {
            if ($_.Role -ne "Primary")
            {
                $IsSecondary = $true
            }
        }
        return $IsSecondary
    }
}

function DisableEnableTrafficManagerEndPoint([Int]$index, $EndpointName, $ProfileName, $Rg, $EnableOrDisableMode)
{
    # Due to the error in cmd Disable-AzureRmTrafficManagerEndpoint we have to use this cmd
	# $index 0= Melbourne, 1 = Sydney
	
	$profile = Get-AzureRmTrafficManagerProfile -Name $ProfileName -ResourceGroupName $Rg
	if($profile.Endpoints[$index].EndpointStatus -ne $EnableOrDisableMode)
	{
		$profile.Endpoints[$index].EndpointStatus = $EnableOrDisableMode
		Set-AzureRmTrafficManagerProfile -TrafficManagerProfile $profile
	}
	else{
		Write-Warning "The endpoint $EndpointName in profile $ProfileName is already $EnableOrDisableMode"
	}
}

# --------------------------- Main script ---------------------------

Write-Output "Starting switching to $mode..."

$currentTime = (Get-Date).ToUniversalTime()

# Fill vairables based on the the environemnt parameter
$con = Get-AutomationConnection -Name "AzureRunAsConnection"      
$SubscriptionName = Get-AutomationVariable -Name 'SubscriptionName'

# WebApp parameters
$webapp_syd_name = Get-AutomationVariable -Name 'webapp_syd_name'
$webapp_mel_name = Get-AutomationVariable -Name 'webapp_mel_name'
$webapp_syd_rg = Get-AutomationVariable -Name 'webapp_syd_rg'
$webapp_mel_rg = Get-AutomationVariable -Name 'webapp_mel_rg'
$SydConString = Get-AutomationVariable -Name 'SydConString'
$MelConString = Get-AutomationVariable -Name 'MelConString'

# Db parameters
$dbName = Get-AutomationVariable -Name 'DbName'
$melDbServer = Get-AutomationVariable -Name 'melDbServer'
$sydDbServer = Get-AutomationVariable -Name 'sydDbServer'
$melDbRg = Get-AutomationVariable -Name 'melDbRg'
$sydDbRg = Get-AutomationVariable -Name 'sydDbRg'

# Traffic manager parameters
$trafficManagerProfileName = Get-AutomationVariable -Name 'TrafficManagerProfileName'
$trafficManagerRg = Get-AutomationVariable -Name 'TrafficManagerRg'
$melEndPoint = Get-AutomationVariable -Name 'melEndPoint'
$sydEndPoint = Get-AutomationVariable -Name 'sydEndPoint'


try
{
    "Logging in to Azure..."
    $null = Add-AzureRmAccount -ServicePrincipal -TenantId $con.TenantId -ApplicationId $con.ApplicationId -CertificateThumbprint $con.CertificateThumbprint
    $null = Select-AzureRmSubscription -SubscriptionName $SubscriptionName

	Write-Output "Configuring connectionstrings in WebApps..."
	if(($mode -eq "Sydney") -or ($mode -eq "both"))
	{
		$connStrings =  @{ 'DefaultConnection' = @{ Type = 'SQLAzure'; Value = "$SydConString" }; };
	}
	elseif($mode -eq "Melbourne")
	{
		$connStrings =  @{ 'DefaultConnection' = @{ Type = 'SQLAzure'; Value = "$MelConString" }; };
	}
	$null = Set-AzureRmWebApp -Name $webapp_syd_name -ResourceGroupName $webapp_syd_rg -ConnectionStrings $connStrings
	$null = Set-AzureRmWebApp -Name $webapp_mel_name -ResourceGroupName $webapp_mel_rg -ConnectionStrings $connStrings

	Write-Output "Initiating failover to switch db..."
	if(($mode -eq "Sydney") -or ($mode -eq "both"))
	{
		InitiatePlannedDbFailover -dbName $dbName -Rg $sydDbRg -ServerName $sydDbServer -PartnerRg $melDbRg -AllowDataLoss $AllowDataLoss
	}
	elseif($mode -eq "Melbourne")
	{
		InitiatePlannedDbFailover -dbName $dbName -Rg $melDbRg -ServerName $melDbServer -PartnerRg $sydDbRg -AllowDataLoss $AllowDataLoss
	}

	Write-Output "Enabling/disabling Traffic Manager endpoints..."
	# index 0 = Mel and 1 = Syd
	if($mode -eq "Sydney")
	{
		Write-Output "Disable Melbourne endpoint and enable Sydney"
		$null = DisableEnableTrafficManagerEndPoint -index 0 -EndpointName $melEndPoint -ProfileName $trafficManagerProfileName -rg $trafficManagerRg -EnableOrDisableMode "Disabled"
		$null = DisableEnableTrafficManagerEndPoint -index 1 -EndpointName $sydEndPoint -ProfileName $trafficManagerProfileName -rg $trafficManagerRg -EnableOrDisableMode "Enabled"
	}
	elseif($mode -eq "Melbourne")
	{
		Write-Output "Disable Sydney endpoint and enable Melbourne"
		$null = DisableEnableTrafficManagerEndPoint -index 0 -EndpointName $melEndPoint -ProfileName $trafficManagerProfileName -rg $trafficManagerRg -EnableOrDisableMode "Enabled"
		$null = DisableEnableTrafficManagerEndPoint -index 1 -EndpointName $sydEndPoint -ProfileName $trafficManagerProfileName -rg $trafficManagerRg -EnableOrDisableMode "Disabled"
	}
	elseif($mode -eq "both")
	{
		Write-Output "Enable both Sydney and Melbourne"
		$null = DisableEnableTrafficManagerEndPoint -index 0 -EndpointName $melEndPoint -ProfileName $trafficManagerProfileName -rg $trafficManagerRg -EnableOrDisableMode "Enabled"
		$null = DisableEnableTrafficManagerEndPoint -index 1 -EndpointName $sydEndPoint -ProfileName $trafficManagerProfileName -rg $trafficManagerRg -EnableOrDisableMode "Enabled"
	}
}
catch 
{
	Write-Error -Message $_.Exception
    throw $_.Exception
}
finally
{
	Write-Output "Runbook finished (Duration: $(("{0:hh\:mm\:ss}" -f ((Get-Date).ToUniversalTime() - $currentTime))))"
}