Function New-UnifiSSH {
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param (
        [Parameter(ParameterSetName = 'DeviceIP',
            Position = 0,
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$deviceIP
    )
    Begin {
        Import-Module Posh-SSH
        Write-Output "Starting: ($($MyInvocation.MyCommand.Name))"
        $Pass = New-Object System.Management.Automation.PSCredential -ArgumentList ubnt, (Read-Host 'Please enter password' | ConvertTo-SecureString -AsPlainText -Force)

        $deviceArray = @()
        $deviceArray += $deviceIP
    }
    Process {
        if ($PSCmdlet.ShouldProcess($deviceIP)) {
    
            $SSHSession = New-SSHSession -ComputerName $deviceArray -Credential $Pass
    
            Foreach ($Device in $SSHSession) {
    
                Invoke-SSHCommand -SSHSession $Device -Command "set-inform http://publicIPAddress:8080/inform" -EnsureConnection:$true
    
            }
        }#if
    }#Process
    End {Get-SSHSession | Remove-SSHSession}
}#Function