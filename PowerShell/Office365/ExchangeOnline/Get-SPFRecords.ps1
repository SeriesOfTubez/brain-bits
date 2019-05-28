#Get Accepted Domains from Exchange Online
$acceptedDomains = Get-AcceptedDomain | select-object -expandproperty domainname

#Function to get SPF Records for all accepted domains
Function Get-SPFRecords{
    $output = "$env:USERPROFILE\Documents\Scripts\Output\SPF_Records.csv"
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
}

#Function to get MX records for all accepted domains
Function Get-MXRecords{
    $output = "$env:USERPROFILE\Documents\Scripts\Output\MX_Records.csv"
    Foreach ($domain in $acceptedDomains){
        try{
            $result = Resolve-DnsName -Name $domain -type MX -ErrorAction Stop # | where-object {$_.Strings -like '*v=spf1*'}
            If ($result){
            $result | Select-Object Name,TTL,NameExchange,Preference | Export-CSV -Append -NoTypeInformation -Path $output
            }
            Else{
                [PSCustomObject]@{'Name'=$domain;'NameExchange'='No Record Found'} | export-csv -append -NoTypeInformation -Force -path $output
            }
        }
        catch {
            [PSCustomObject]@{'Name'=$domain;'NameExchange'=$_} | export-csv -append -NoTypeInformation -Force -path $output
        }
    }
}

#Function to get all MX records that are directed to non-compliant MTAs.  Must modify the '-notlike' statement to match your mail solution.  Assumes O365 and Proofpoint in use.
Function Get-NonCompliantMXRecords{
    $output = "$env:USERPROFILE\Documents\Scripts\Output\NonCompliant_MX_Records.csv"
    Foreach ($domain in $acceptedDomains){
        try{
            $result = Resolve-DnsName -Name $domain -type MX -ErrorAction Stop
            If ($result){
            $result | where-object {$_.Name -notlike '*onmicrosoft.com*' -and $_.NameExchange -notlike '*gslb.pphosted.com*'} | Select-Object Name,TTL,NameExchange,Preference | Export-CSV -Append -NoTypeInformation -Path $output
            }
            Else{
                [PSCustomObject]@{'Name'=$domain;'NameExchange'='No Record Found'} | export-csv -append -NoTypeInformation -Force -path $output
            }
        }
        catch {
            [PSCustomObject]@{'Name'=$domain;'NameExchange'=$_} | export-csv -append -NoTypeInformation -Force -path $output
        }
    }
}
