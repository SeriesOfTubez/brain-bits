$path64 = '\\path\to\sysmon64.exe'
$path32 = '\\path\to\sysmon.exe'
$conf = '\\path\to\sysmonconfig.xml'
$arg = '-accepteula -i ' + "$conf"
$argUpdate = '-c ' + "$conf"
$os_arch = test-path 'C:\Program Files (x86)'

#Handles 64-bit and 32-bit systems
If ($os_arch -eq "True"){
    #Check if sysmon64.exe exists
    If (Test-Path $env:windir\sysmon64.exe){
        #Update existing sysmon64.exe config
        Start-Process -FilePath $path64 -ArgumentList $argUpdate -Wait -WindowStyle Hidden}
    Else {
        #Install Sysmon64
        Start-Process -FilePath $path64 -ArgumentList $arg -Wait -WindowStyle Hidden
        }
    }
Else {
    #Check if sysmon.exe exists
    If (Test-Path $env:windir\sysmon.exe){
        #Update existing sysmon.exe config
        Start-Process -FilePath $path32 ArgumentList $argUpdate -Wait -WindowStyle Hidden}
    Else {
        #Install Sysmon
        Start-Process -FilePath $path32 -ArgumentList $arg -Wait -WindowStyle Hidden}
     }
