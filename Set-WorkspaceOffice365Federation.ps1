<#
    .Synopsis
        Citrix Workspace and Microsoft Office 365 Federation
    .Description
        Retrieve Citrix Workspace SAML IdP certificate
        Configure Microsoft Office 365 Authentication
    .Example
        Set-WorkspaceOffice365Federation.ps1 -CustomerId dcint1234567 -Domain example.com -Branding "Example, Inc." -WorkspaceUrl "https://example.cloud.com"
    .Example
        Set-WorkspaceOffice365Federation.ps1 -CustomerId dcint7654321 -Domain myworkspace.com -Branding "My Workspace" -WorkspaceUrl "https://myworkspace.cloud.com" -Force
    .Notes
        Contributors:
            Ed York, Bobby Elliott, Scott Lane, Adam Cooperman, Landon Fraley
    .Link
        https://www.citrix.com/digital-workspace/sso-for-saas-apps.html
        https://docs.citrix.com/en-us/citrix-cloud/access-control.html
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
     [string]$CustomerId,     # Citrix Cloud customerid, listed on "API Access" page
    [Parameter(Mandatory=$True)]
     [string]$Domain,         # O365 validated domain to federate with Workspace
    [Parameter(Mandatory=$False)]
     [string]$Branding,       # Name displayed to users, i.e. personalization/branding
    [Parameter(Mandatory=$True)]
     [string]$WorkspaceUrl,   # Citrix Workspace URL
    [Parameter(Mandatory=$False)]
     [switch]$Force           # Reset authentication to Managed, use with caution.
)

# Download Workspace SAML IdP Metadata XML and set IssuerURI
$Url = "https://gateway.cloud.com/idp/saml/"+ $CustomerId + "/idp_metadata.xml"
Write-Verbose $Url
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[xml]$Xml = Invoke-WebRequest -Uri $Url
$IssuerUri = $Xml.EntityDescriptor.entityID
Write-Verbose $IssuerUri

# Convert Citrix Workspace Signing Certificate to base64 string
Write-Verbose "Signing Certificate"
Write-Verbose $Xml.EntityDescriptor.IDPSSODescriptor.KeyDescriptor.KeyInfo.X509Data.X509Certificate
$Cert = [Convert]::FromBase64String($xml.EntityDescriptor.IDPSSODescriptor.KeyDescriptor.KeyInfo.X509Data.X509Certificate)
$CertObj = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$CertObj.Import($Cert)
$CertData = [System.Convert]::tobase64string($CertObj.RawData)

# Install, import and connect to MSOnline (Azure AD)
if (!(Get-Module -ListAvailable -Name MSOnline)) {
    Write-Host "MSOnline module required. Installing.."
    Install-Module -Name MSOnline
}
Import-Module MSOnline
Connect-MsolService

# If $Domain is already configured for federation, e.g. AD Connect configured to use Federated
# authentication with ADFS, the below command may be required; It resets O365 authentication to Managed
# so the federated configuration can be applied. Use the -Force switch to enable it.
if  ($Force){ 
    Write-Verbose "Setting $Domain domain authentication to Managed"
    Set-MsolDomainAuthentication –Authentication Managed –DomainName $Domain
}

# Configure Office 365 domain for federation with Citrix Workspace
Set-MsolDomainAuthentication -DomainName $Domain -FederationBrandName $Branding -Authentication Federated -PassiveLogOnUri $WorkspaceUrl -SigningCertificate $CertData -IssuerUri $IssuerUri -ActiveLogOnUri $WorkspaceUrl -LogOffUri $WorkspaceUrl -PreferredAuthenticationProtocol SAMLP 
Get-MsolDomainFederationSettings -DomainName $Domain