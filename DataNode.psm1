
#region load_dlls
Add-Type -Path (Join-Path $PSScriptRoot 'DataNode.Core.dll')
#endregion

#region const
enum FileFormat {psd1; json; xml; csv; }

#endregion

#region item

function New-dnAttribute {
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([DataNode.Core.Attribute], ParameterSetName="Default")]

    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Name,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateScript({ $_ -is [string] -or $_ -is [int] -or $_ -is [decimal] })]
        [object]$Value
    )

    switch ($PSCmdlet.ParameterSetName) {
        'Default' {
            return [DataNode.Core.Attribute]::new($Name, $Value);
            break
        }
    }
}

Set-Alias -Name:ndna -Value:New-dnAttribute
Export-ModuleMember -Function:New-dnAttribute
Export-ModuleMember -Alias:ndna

function New-dnItem {
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([DataNode.Core.Item], ParameterSetName="Default")]

    param (
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Attribute] $Attribute,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Key
    )

    begin {
        $attributes = New-Object 'System.Collections.Generic.List[DataNode.Core.Attribute]'
    }
    
    process {
        if ($Attribute) {
            $attributes.Add($Attribute);
        }
    }

    end {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return [DataNode.Core.Item]::new($attributes, $Key, $null);
                break
            }
        }        
    }
}

Set-Alias -Name:ndni -Value:New-dnItem
Export-ModuleMember -Function:New-dnItem
Export-ModuleMember -Alias:ndni

function Copy-dnItem {
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([DataNode.Core.Item], ParameterSetName="Default")]

    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [DataNode.Core.Item] $From,

        [Parameter(Mandatory = $false, Position = 1)]
        [string] $Key
    )

    begin {
    }
    
    process {
    }

    end {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $From.Copy($Key);
                break
            }
        }        
    }
}

Set-Alias -Name:cpdni -Value:Copy-dnItem
Export-ModuleMember -Function:Copy-dnItem
Export-ModuleMember -Alias:cpdni

function Get-dnAttribute {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Attribute], ParameterSetName="Default")]
    [OutputType([DataNode.Core.Attribute], ParameterSetName="All")]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [DataNode.Core.Item] $Item,

        [Alias('Name')]
        [Parameter(Mandatory = $false, Position = 0)] [string[]] $AttributeName,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateScript({ $_ -is [string] -or $_ -is [int] -or $_ -is [decimal] })]
        [object]$DefaultValue,

        [Parameter(ParameterSetName = 'All')]
        [switch] $All
    )

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                foreach ($name in $AttributeName) 
                {
                    $attribute = ($null -eq $DefaultValue) ? 
                        $Item.Get($name) : 
                        $Item.GetOrDefault($name, $DefaultValue);
                    $attribute | Write-Output;                    
                }
                break
            }
            'All' {
                $Item.GetAll() | Write-Output;
                break
            }
        }
    }
}

Set-Alias -Name:gdna -Value:Get-dnAttribute
Export-ModuleMember -Function:Get-dnAttribute
Export-ModuleMember -Alias:gdna

function Set-dnAttribute {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Attribute])]

    param (
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Attribute] $Attribute,

        [Parameter(Mandatory = $true, Position = 0)] 
        [DataNode.Core.Item] $Item,

        [Parameter(ParameterSetName = 'Name')]
        [Alias('Name')]
        [Parameter(Mandatory = $false, Position = 1)] 
        [string] $AttributeName,

        [Parameter(ParameterSetName = 'Name')]
        [Parameter(Mandatory = $false, Position = 2)] 
        [ValidateScript({ $_ -is [string] -or $_ -is [int] -or $_ -is [decimal] })]        
        [object]$Value,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Name')]
        [switch] $ExistingOnly
    )

    begin {
        $attributes = New-Object 'System.Collections.Generic.List[DataNode.Core.Attribute]'
    }
    process {
        if ($Attribute) {
            $attributes.Add($Attribute);
        }
    }
    end 
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $Item.SetAll($attributes, $ExistingOnly);
                break
            }
            'Name' {
                return $Item.Set($AttributeName, $Value, $ExistingOnly);
                break
            }            
        }
    }
}

Set-Alias -Name:sdna -Value:Set-dnAttribute
Export-ModuleMember -Function:Set-dnAttribute
Export-ModuleMember -Alias:sdna

function Add-dnAttribute {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Attribute])]

    param (
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Attribute] $Attribute,

        [Parameter(Mandatory = $true, Position = 0)] 
        [DataNode.Core.Item] $Item,

        [Parameter(ParameterSetName = 'Name')]
        [Alias('Name')]
        [Parameter(Mandatory = $false, Position = 1)] 
        [string] $AttributeName,

        [Parameter(ParameterSetName = 'Name')]
        [Parameter(Mandatory = $false, Position = 2)] 
        [ValidateScript({ $_ -is [string] -or $_ -is [int] -or $_ -is [decimal] })]        
        [object]$Value
    )

    begin {
        $attributes = New-Object 'System.Collections.Generic.List[DataNode.Core.Attribute]'
    }
    process {
        if ($Attribute) {
            $attributes.Add($Attribute);
        }
    }
    end 
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $Item.AddAll($attributes);
                break
            }
            'Name' {
                return $Item.Add($AttributeName, $Value);
                break
            }
        }
    }
}

Set-Alias -Name:adna -Value:Add-dnAttribute
Export-ModuleMember -Function:Add-dnAttribute
Export-ModuleMember -Alias:adna

function Remove-dnAttribute {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Attribute])]

    param (
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Attribute] $Attribute,

        [Parameter(Mandatory = $true, Position = 0)] 
        [DataNode.Core.Item] $Item,

        [Parameter(ParameterSetName = 'Name')]
        [Alias('Name')]
        [Parameter(Mandatory = $false, Position = 1)] 
        [string[]] $AttributeName
    )

    begin {
        $attributes = New-Object 'System.Collections.Generic.List[DataNode.Core.Attribute]'
    }
    process {
        if ($Attribute) {
            $attributes.Add($Attribute);
        }
    }
    end 
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $Item.RemoveAll($attributes);
                break
            }
            'Name' {
                return $Item.RemoveAll($AttributeName);
                break
            }
        }
    }
}

Set-Alias -Name:rmdna -Value:Remove-dnAttribute
Export-ModuleMember -Function:Remove-dnAttribute
Export-ModuleMember -Alias:rmdna

#endregion

#region node

function New-DataNode {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([DataNode.Core.DataNode], ParameterSetName = "Default")]

    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Copy')]
        [DataNode.Core.DataNode] $CopyFrom
    )

    switch ($PSCmdlet.ParameterSetName) {
        'Default' {
            return [DataNode.Core.DataNode]::new();
            break
        }
        'Copy' {
            return [DataNode.Core.DataNode]::Copy($CopyFrom);
            break
        }
    }
}
Set-Alias -Name:ndn -Value:New-DataNode
Export-ModuleMember -Function:New-DataNode
Export-ModuleMember -Alias:ndn

function Get-dnItem {
    [CmdletBinding(DefaultParameterSetName='Default')]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('DN', 'Node')]
        [DataNode.Core.DataNode] $DataNode,

        [Parameter(ParameterSetName = 'Key')] 
        [Parameter(Mandatory = $false, Position = 0)] [string] $Key,

        [Alias('Hashtable', 'Hash')]
        [switch] $AsHashtable = $false

    )

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                $dict = $AsHashtable ? @{} : [System.Collections.Generic.Dictionary[string, DataNode.Core.Item]]::new();
                $all = $DataNode.Get();
                foreach ($key in $all.Keys) 
                    { $dict[$key] = ($AsHashtable ? (Get-Attribute -Item $all[$key] -AsHashtable) : $all[$key]); }
                return $dict;
                break
            }
            'Key' {
                return $DataNode.Get($Key);
                break
            }
        }
    }
}

Set-Alias -Name:geti -Value:Get-dnItem
Export-ModuleMember -Function:Get-dnItem
Export-ModuleMember -Alias:geti

function Set-dnItem {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.DataNode])]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] 
        [Alias('DN', 'Node')]
        [DataNode.Core.DataNode] $DataNode,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false)] 
        [System.Collections.Generic.Dictionary[string, DataNode.Core.Item]] $All,

        [Parameter(ParameterSetName = 'Hashtable')]
        [Parameter(Mandatory = $false)] 
        [hashtable] $HashtableAll,

        [Parameter(ParameterSetName = 'Item')]
        [Parameter(Mandatory = $false, Position = 0)] 
        [DataNode.Core.Item[]] $Item,

        [switch] $ExistingOnly = $false
    )

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $DataNode.SetAll($All, $ExistingOnly);
                break
            }
            'Hashtable' {
                $dict = [System.Collections.Generic.Dictionary[string, DataNode.Core.Item]]::new()
                foreach ($key in $HashtableAll.Keys) 
                    { $dict[$key] =  $HashtableAll[$key]; }
                return $DataNode.SetAll($dict, $ExistingOnly);
                break
            }
            'Item' {
                foreach ($i in $Item) 
                    { $DataNode.Set($i, $ExistingOnly) | Out-Null; }
                return $DataNode;
                break;
            }
        }
    }   
}

Set-Alias -Name:seti -Value:Set-dnItem
Export-ModuleMember -Function:Set-dnItem
Export-ModuleMember -Alias:seti

function Add-dnItem {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.DataNode])]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [DataNode.Core.DataNode] $DataNode,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false)] [System.Collections.Generic.Dictionary[string, DataNode.Core.Item]] $All,

        [Parameter(ParameterSetName = 'Hashtable')]
        [Parameter(Mandatory = $false)] [hashtable] $HashtableAll,

        [Parameter(ParameterSetName = 'Item', Position = 0)]
        [Parameter(Mandatory = $false)] [DataNode.Core.Item[]] $Item

    )

    begin {
        $ErrorActionPreference = 'Stop';
    }

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $DataNode.AddAll($All);
                break
            }
            'Hashtable' {
                $dict = [System.Collections.Generic.Dictionary[string, DataNode.Core.Item]]::new()
                foreach ($key in $HashtableAll.Keys) { $dict[$key] = $HashtableAll[$key]; }
                return $DataNode.AddAll($dict);
                break
            }
            'Item' {
                foreach ($i in $Item) { $DataNode.Add($i) | Out-Null; }
                return $DataNode;
                break
            }     
        }
    }
}

Set-Alias -Name:addi -Value:Add-dnItem
Export-ModuleMember -Function:Add-dnItem
Export-ModuleMember -Alias:addi

function Remove-dnItem {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.DataNode])]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [DataNode.Core.DataNode] $DataNode,

        [Parameter(Mandatory = $true, Position = 0)] [string] $Key

    )

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                $DataNode.Remove($Key);
                break
            }            
        }
    }
}

Set-Alias -Name:rmi -Value:Remove-dnItem
Export-ModuleMember -Function:Remove-dnItem
Export-ModuleMember -Alias:rmi

#endregion


#region export

<#
    .SYNOPSIS
    Imports FlatTree stored in a file.
    Supported formats : psd1.

    .PARAMETER FileInfo
    Object returned by Get-ChildItem, Get-Item from FileProvider

    .EXAMPLE
    PS> $tree = gi .\test.psd1 | iptree ;


#>
function Import-Tree {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.IO.FileInfo] $FileInfo
    )

    [string] $ext = $FileInfo.Extension;
    switch ($ext) {
            { $_ -eq ("." + [FileFormat]::psd1) } { 
                [hashtable] $tree = Import-PowerShellDataFile -Path:($FileInfo.FullName) -SkipLimitCheck ;
                break; 
            }
            default { throw "File format '$ext' not supported." }
    }
    $root = Get-Node -Tree:$tree -PatternPath:'0';
    if (-not $root) { throw "Root not found." }
    if ($root -isnot [hashtable]) { throw "Multiple nodes found for the path." }

    Set-AttributeValue -Node:$root -Key:([SysAttrKey]::FilePath) -V:($FileInfo.FullName) -System;
    return $tree;
}

Set-Alias -Name:iptree -Value:Import-Tree
Export-ModuleMember -Function:Import-Tree
Export-ModuleMember -Alias:iptree

function Get-ValuePsd1 {
    param (
        [Parameter(Mandatory = $false)] [object] $value
    )

    if ($value -is [string]) { $formatted = "'$($value)'"; }
    elseif ($value -is [boolean]) { $formatted = $value ? "`$true" : "`$false"; }
    elseif ($null -eq $value) { $formatted = "`$null"; }
    else { $formatted = $value; }

    return $formatted;
}

function Get-AttributeLinesPsd1 {
    param (
        [Parameter(Mandatory = $true)] [hashtable] $attr,
        [Parameter(Mandatory = $false)] [int] $offset = 0
    )

    $outputLines = New-Object 'System.Collections.Generic.List[string]';
    $attrLines = New-Object 'System.Collections.Generic.List[string]';

    $keys = ($attr.Keys | Sort-Object);

    foreach ($key in $keys) 
    {
        if ($null -eq $attr[$key]) { continue; } 
        $attrLines.Add("$("`t" * $offset)`t'${key}' = $(Get-ValuePsd1 -value:($attr[$key]));"); 
    }

    if ($attrLines.Count -eq 0) {
        $outputLines.Add("@{};");
    }
    else {
        $outputLines.Add("$("`t" * $offset)@{");
        $outputLines.AddRange($attrLines);
        $outputLines.Add("$("`t" * $offset)};");        
    }

    return ,$outputLines;
}

function Get-NodeLinesPsd1 {
    param (
        [Parameter(Mandatory = $true)] [hashtable] $Node,
        [Parameter(Mandatory = $false)] [int] $offset = 0
    )

    $output = New-Object 'System.Collections.Generic.List[string]';
    $output.Add("$("`t" * $offset)@{");

    $lines = (Get-AttributeLinesPsd1 -attr:($Node[$SA]) -offset:($offset + 1));
    if ($lines.Count -eq 1) { $output.Add("$("`t" * $offset)'${SA}' = " + $lines[0]); }
    else { 
        $output.Add("$("`t" * $offset)'${SA}' = ");
        $output.AddRange($lines); 
    }

    $lines = (Get-AttributeLinesPsd1 -attr:($Node[$A]) -offset:($offset + 1));
    if ($lines.Count -eq 1) { $output.Add("$("`t" * $offset)'${A}' = " + $lines[0]); }
    else { 
        $output.Add("$("`t" * $offset)'${A}' = ");
        $output.AddRange($lines); 
    }

    $output.Add("$("`t" * $offset)};");

    return ,$output;
}

function Get-TreeContentPsd1 {
    param (
        [Parameter(Mandatory = $true)] [hashtable] $tree
    )

    $output = New-Object 'System.Collections.Generic.List[string]';
    $output.Add("@{");

    [string[]] $keys = $tree.Keys | Sort-Object;
    foreach ($key in $keys) 
    {
        $output.Add("`t'${key}' =");
        $output.AddRange((Get-NodeLinesPsd1 -Node:($tree[$key]) -offset:2 ));
    }

    $output.Add("};");

    return $output.ToArray() -join "`n";
}

<#
    .SYNOPSIS
    Exports FlatTree to the file.
    Supported formats : psd1.

    .PARAMETER Tree
    Hashtable comtaining FlatTree.

    .PARAMETER Path
    Path in a FileSystem provider.

    .EXAMPLE
    PS> $tree = gi .\test.psd1 | iptree ;
    PS> $tree | eptree -F:"./test-copy.psd1"    #   creating a copy, it's not the same as cp because file path is stored in root node

#>
function Export-Tree {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)] 
        [hashtable] $Tree,

        [Parameter(Mandatory = $false)] [string] $FilePath
    )

    Process {
        $root = Get-Node -Tree:$Tree -PatternPath:'0';
        if (-not $root) { throw "Root not found." }
        if ($root -isnot [hashtable]) { throw "Multiple nodes found for the path." }

        if ( -not $FilePath) { 
            $FilePath = (Get-AttributeValue -Node:$root -Key:([SysAttrKey]::FilePath) -System) 
        }
        if (-not $FilePath) { throw "File Path not specified." }

        [string] $fullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FilePath);
        Set-AttributeValue -Node:$root -Key:([SysAttrKey]::FilePath) -Value:$fullPath -System

        [string] $ext = [System.IO.Path]::GetExtension($FilePath);

        switch ($ext) {
            { $_ -eq ("." + [FileFormat]::psd1) } { 
                [string] $content = Get-TreeContentPsd1 -Tree:$Tree;
                break; 
            }
            default { throw "File format '$ext' not supported." }
        }

        Set-Content -Path:$FilePath -Value:$content -Encoding UTF8 -Force;
        Get-Item -Path:$FilePath;           
    }
}

Set-Alias -Name:eptree -Value:Export-Tree
Export-ModuleMember -Function:Export-Tree
Export-ModuleMember -Alias:eptree
#endregion
