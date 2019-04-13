#Auth to O365 Tenant
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking -AllowClobber

#Get all accepted domains from Exchange Online
$acceptedDomains = Get-AcceptedDomain | select-object -expandproperty domainname

#Set path for exported CSV
$output = "$env:USERPROFILE\Documents\Scripts\Output\SPF_Records.csv"

#Loop through all Accepted Domains and lookup SPF records
Foreach ($domain in $acceptedDomains){
    try{
        $result = Resolve-DnsName -Name $domain -type txt -ErrorAction Stop | where-object {$_.Strings -like '*v=spf1*'}
        If ($result){
        $result | Select-Object @{Name="DomainName";Expression={$_.Name}},@{Name="Record";Expression={$_.Strings}} | Export-CSV -Append -NoTypeInformation -Path $output
        }
        Else{
            [PSCustomObject]@{'DomainName'=$domain;'Record'='No Record Found'} | export-csv -append -NoTypeInformation -Force -path $output
        }
    }
    catch {
        [PSCustomObject]@{'DomainName'=$domain;'Record'=$_} | export-csv -append -NoTypeInformation -Force -path $output
    }
}
