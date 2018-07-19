<# ++++++++++++++++++++++++++++++++++++++++++++++
Get-TargetResource
+++++++++++++++++++++++++++++++++++++++++++++++++ #>
function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [string]
        $Value,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Machine", "User")]
        [string]
        $Target = 'Machine'
    )
    $GetRes = @{
        Ensure = $Ensure
        Value  = $Value
        Target = $Target
    }

    $EnvList = Get-EnvironmentPath -Target $Target -ErrorAction Stop

    if ($EnvList -eq $Value) {
        $GetRes.Ensure = 'Present'
    }
    else {
        $GetRes.Ensure = 'Absent'
    }

    $GetRes
} # end of Get-TargetResource


<# ++++++++++++++++++++++++++++++++++++++++++++++
Test-TargetResource
+++++++++++++++++++++++++++++++++++++++++++++++++ #>
function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [string]
        $Value,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Machine", "User")]
        [string]
        $Target = 'Machine'
    )

    return ((Get-TargetResource @PSBoundParameters).Ensure -eq $Ensure)
} # end of Test-TargetResource

<# ++++++++++++++++++++++++++++++++++++++++++++++
Set-TargetResource
+++++++++++++++++++++++++++++++++++++++++++++++++ #>
function Set-TargetResource {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [string]
        $Value,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Machine", "User")]
        [string]
        $Target = 'Machine'
    )
    $ErrorActionPreference = 'Stop'

    if ($Ensure -eq 'Absent') {
        #Remove Value
        Write-Verbose ('Remove Value "{0}" from PATH' -f $Value)
        Remove-EnvironmentPath -Path $Value -Target $Target | Out-Null
    }
    elseif ($Ensure -eq 'Present') {
        #Add Value
        Write-Verbose ('Add Value "{0}" to PATH' -f $Value)
        Add-EnvironmentPath -Path $Value -Target $Target | Out-Null
    }

} # end of Set-TargetResource


<# ++++++++++++++++++++++++++++++++++++++++++++++
環境変数PATHの値を取得する
+++++++++++++++++++++++++++++++++++++++++++++++++ #>
function Get-EnvironmentPath {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet("User", "Machine")]
        [string]$Target # UserかMachineか選ぶ
    )

    $PathEnv = New-Object System.Collections.ArrayList
    ([System.Environment]::GetEnvironmentVariable("Path", $Target)) -split ';' | ForEach-Object {$PathEnv.Add($_)} | Out-Null
    $PathEnv
}

<# ++++++++++++++++++++++++++++++++++++++++++++++
環境変数PATHから指定の値を削除する
+++++++++++++++++++++++++++++++++++++++++++++++++ #>
function Remove-EnvironmentPath {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Path, # 削除する値

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet("User", "Machine")]
        [string]$Target # UserかMachineか選ぶ
    )

    $PathEnv = New-Object System.Collections.ArrayList
    ([System.Environment]::GetEnvironmentVariable("Path", $Target)) -split ';' | ForEach-Object {$PathEnv.Add($_)} | Out-Null
    if ($PathEnv -contains $Path) {
        $PathEnv = ($PathEnv -ne $Path)
        [System.Environment]::SetEnvironmentVariable("Path", ($PathEnv -join ';'), $Target)
    }
    [System.Environment]::GetEnvironmentVariable("Path", $Target)
}

<# ++++++++++++++++++++++++++++++++++++++++++++++
環境変数PATHの末尾に指定の値を追加する
+++++++++++++++++++++++++++++++++++++++++++++++++ #>
function Add-EnvironmentPath {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Path, # 追加する値

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet("User", "Machine")]
        [string]$Target # UserかMachineか選ぶ
    )

    $PathEnv = New-Object System.Collections.ArrayList
    ([System.Environment]::GetEnvironmentVariable("Path", $Target)) -split ';' | ForEach-Object {$PathEnv.Add($_)} | Out-Null
    if ($PathEnv -notcontains $Path) {
        $PathEnv.Add($Path)
        [System.Environment]::SetEnvironmentVariable("Path", ($PathEnv -join ';'), $Target)
    }
    [System.Environment]::GetEnvironmentVariable("Path", $Target)
}

# ////////////////////////////////////////////////////////////////////////////////////////
Export-ModuleMember -Function *-TargetResource
