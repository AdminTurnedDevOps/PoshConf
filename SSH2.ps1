Function New-SSHConnection {
    
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param (
        [Parameter(ParameterSetName = 'DeviceIP',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$deviceIP,

        [Parameter(ParameterSetName = 'DeviceHostname',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$Hostname,

        [Parameter(Mandatory,
            HelpMessage = 'Please enter a command you would like to run on the device')]
        [string]$Command,

        [Parameter(Mandatory,
            HelpMessage = 'Please enter a username for your device you want to SSH into')]
        [string]$Username

    )
    Begin {
        Add-Type -AssemblyName System;
        Add-Type -AssemblyName System.Management.Automation;

        Import-Module Posh-SSH
        Write-Output "Starting: ($($MyInvocation.MyCommand.Name))"
        $Pass = New-Object System.Management.Automation.PSCredential -ArgumentList  $Username, (Read-Host 'Please enter password' | ConvertTo-SecureString -AsPlainText -Force)
        
        #If DeviceIP is selected, use this array
        $deviceArray = @()
        $deviceArray += $deviceIP

        #If Hostname is selected, use this array
        $deviceArray2 = @()
        $deviceArray2 += $Hostname
    }
    Process {
        if ($PSCmdlet.ShouldProcess($deviceIP -or $PSCmdlet.ShouldProcess($Hostname))) {
            if ($deviceIP) {
                $SSHSession = New-SSHSession -ComputerName $deviceArray -Credential $Pass
            }   

            elseif ($Hostname) {
                $SSHSession = New-SSHSession -ComputerName $deviceArray -Credential $Pass
            }
        }
    
        Foreach ($Device in $SSHSession) {
            $invokeSSHCommandPARAMS = @{
                'SSHSession'       = $Device
                'Command'          = $Command
                'EnsureConnection' = $true
            }
            $invokeSSHCommand = Invoke-SSHCommand @invokeSSHCommandPARAMS
            
            $invokeSSHCommandOBJECT = [pscustomobject] @{
                'IP_or_Host'    = $invokeSSHCommand.Host
                'CommandOutput' = $invokeSSHCommand.Output
            }
            $invokeSSHCommandOBJECT

            Start-sleep -Seconds 7
        }           
    }#Process
    End {Get-SSHSession | Remove-SSHSession}
}#Function
