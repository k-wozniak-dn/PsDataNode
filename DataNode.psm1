
#region load_dlls
Add-Type -Path (Join-Path $PSScriptRoot 'DataNode.Core.dll')
#endregion

#region const
enum FileFormat {psd1; json; xml; csv; }

#endregion

#region item

function New-DataNodeItem {
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([DataNode.Core.Item], ParameterSetName="Default")]

    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Key,

        [Parameter(Mandatory = $false, Position = 1)]
        [DataNode.Core.DataNode] $Parent = $null,

        [Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'Copy')]
        [DataNode.Core.Item] $CopyFrom
    )

    
    switch ($PSCmdlet.ParameterSetName) {
        'Default' {
            return [DataNode.Core.Item]::new($Key, $Parent);
            break
        }
        'Copy' {
            return $CopyFrom.Copy($Key, $Parent);
            break
        }
    }
}

Set-Alias -Name:ndni -Value:New-DataNodeItem
Export-ModuleMember -Function:New-DataNodeItem
Export-ModuleMember -Alias:ndni

function Get-Attribute {
    [CmdletBinding(DefaultParameterSetName='Default')]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [DataNode.Core.Item] $Item,

        [Parameter(ParameterSetName = 'Name')] 
        [Alias('Name')]
        [Parameter(Mandatory = $false, Position = 0)] [string] $AttributeName

    )

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                $dict = [System.Collections.Generic.Dictionary[string, object]]::new()
                foreach ($key in $Item.Attributes.Keys) { $dict[$key] = $Item.Attributes[$key].Value; }
                return $dict;
                break
            }
            'Name' {
                return $Item.Get($Key, $AttributeName).Value;
                break
            }
        }
    }
}

Set-Alias -Name:geta -Value:Get-Attribute
Export-ModuleMember -Function:Get-Attribute
Export-ModuleMember -Alias:geta

function Set-Attribute {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Item])]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [DataNode.Core.Item] $Item,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false)] [System.Collections.Generic.Dictionary[string, object]] $All,

        [Parameter(ParameterSetName = 'Hashtable')]
        [Parameter(Mandatory = $false)] [hashtable] $HashtableAll,

        [Parameter(ParameterSetName = 'Name')]
        [Alias('Name')]
        [Parameter(Mandatory = $false, Position = 0)] [string] $AttributeName,

        [Parameter(ParameterSetName = 'Name', Position = 1)]
        [ValidateScript({ $_ -is [string] -or $_ -is [int] -or $_ -is [decimal] })]
        [Parameter(Mandatory = $false)] [object]$Value,

        [switch] $ExistingOnly = $false
    )

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $Item.SetAll($All, $ExistingOnly);
                break
            }
            'Hashtable' {
                $dict = [System.Collections.Generic.Dictionary[string, object]]::new()
                foreach ($key in $HashtableAll.Keys) { $dict[$key] = $HashtableAll[$key]; }
                return $Item.SetAll($dict, $ExistingOnly);
                break
            }
            'Name' {
                return $Item.Set($AttributeName, $Value, $ExistingOnly);
                break
            }            
        }
    }
}

Set-Alias -Name:seta -Value:Set-Attribute
Export-ModuleMember -Function:Set-Attribute
Export-ModuleMember -Alias:seta

function Add-Attribute {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Item])]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [DataNode.Core.Item] $Item,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false)] [System.Collections.Generic.Dictionary[string, object]] $All,

        [Parameter(ParameterSetName = 'Hashtable')]
        [Parameter(Mandatory = $false)] [hashtable] $HashtableAll,

        [Parameter(ParameterSetName = 'Name')]
        [Alias('Name')]
        [Parameter(Mandatory = $false, Position = 0)] [string] $AttributeName,

        [Parameter(ParameterSetName = 'Name', Position = 1)]
        [ValidateScript({ $_ -is [string] -or $_ -is [int] -or $_ -is [decimal] })]
        [Parameter(Mandatory = $false)] [object]$Value

    )

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $Item.AddAll($All);
                break
            }
            'Hashtable' {
                $dict = [System.Collections.Generic.Dictionary[string, object]]::new()
                foreach ($key in $HashtableAll.Keys) { $dict[$key] = $HashtableAll[$key]; }
                return $Item.AddAll($dict);
                break
            }
            'Name' {
                return $Item.Add($AttributeName, $Value);
                break
            }            
        }
    }
}

Set-Alias -Name:adda -Value:Add-Attribute
Export-ModuleMember -Function:Add-Attribute
Export-ModuleMember -Alias:adda


function Remove-Attribute {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Item])]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [DataNode.Core.Item] $Item,

        [Alias('Name')]
        [Parameter(Mandatory = $true, Position = 0)] [string] $AttributeName

    )

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $Item.Remove($AttributeName);
                break
            }            
        }
    }
}

Set-Alias -Name:rma -Value:Remove-Attribute
Export-ModuleMember -Function:Remove-Attribute
Export-ModuleMember -Alias:rma

#endregion

#region node






# function Set-Index {
#     [CmdletBinding(DefaultParameterSetName='Default')]
#     [OutputType([DataNode.Core.DataNode])]

#     param (
#         [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [DataNode.Core.DataNode] $DataNode,

#         [Parameter(Mandatory = $true)] [int] $Index,

#         [Parameter(ParameterSetName = 'Default')]
#         [Parameter(Mandatory = $false)] [DataNode.Core.Attributes] $AllAttributes,

#         [Parameter(ParameterSetName = 'Name')]
#         [Parameter(Mandatory = $false)] [string] $Name,

#         [Parameter(ParameterSetName = 'Name')]
#         [ValidateScript({ $_ -is [string] -or $_ -is [int] -or $_ -is [decimal] })]
#         [Parameter(Mandatory = $false)] [object]$Value
#     )

#     Begin {
#     }

#     Process
#     { 
#         switch ($PSCmdlet.ParameterSetName) {
#             'Default' {
#                 $attributes = $AllAttributes.Copy($DataNode);
#                 $DataNode.Set($Index, $attributes);
#                 break
#             }
#             'Name' {
#                 $attributes = $DataNode.Get($Index);
#                 if ($attributes) { $attributes.Set($Name, $Value); }
#                 else { throw "Attributes not found for the index."; }
#                 break
#             }
#         }

#         Write-Output $DataNode;
#     }
# }

# Set-Alias -Name:sidx -Value:Set-Index
# Export-ModuleMember -Function:Set-Index
# Export-ModuleMember -Alias:sidx


<#
    .SYNOPSIS
    Creates new node and sets initial system attributes.

    .PARAMETER Name

    .EXAMPLE

#>
function New-DataNode {
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([hashtable], ParameterSetName="Default")]

    param (
        [string] $Name
    )

    $dn = [DataNode.Core.DataNode]::new();

    # if ($NodeName) { Set-AttributeValue -Node:$nn -Key:([SysAttrKey]::NodeName) -Value:$NodeName -System ;}
    # Set-AttributeValue -Node:$nn -Key:([SysAttrKey]::NextChildId) -Value:1 -System ;
    #   new node is not indexed until it's added to the tree
    # Set-AttributeValue -Node:$nn -Key:([SysAttrKey]::Idx) -Value:-1 -System ;

    return $dn;
}
Set-Alias -Name:ndn -Value:New-DataNode
Export-ModuleMember -Function:New-DataNode
Export-ModuleMember -Alias:ndn

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
