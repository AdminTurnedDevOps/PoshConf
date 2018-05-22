Function Get-MikesService {
    Param (
        [string]$ComputerName = 'localhost'
    )

    Get-Service -ComputerName $ComputerName | Where-Object {$_.Status -eq 'Stopped'}

}
Get-MikesService
