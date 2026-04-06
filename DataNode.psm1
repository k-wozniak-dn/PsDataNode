
#region load_dlls
$moduleRoot = $PSScriptRoot
$DataNodeCorePath = Join-Path $moduleRoot 'DataNode.Core.dll'
Add-Type -Path $DataNodeCorePath
#endregion

#region const
enum FileFormat {psd1; json; xml; csv; }

#endregion

#region node

<#
    .SYNOPSIS
    Get one or all attributes or system attributes from node. Outputs collection of PSCstomObjects with properties:
    Key, Value, System

    .PARAMETER Node
    Source node.

    .PARAMETER Key
    Attribute key.

    .PARAMETER System
    Switch, if used, system attributes are searched for a key.

    .PARAMETER All
    Switch, if used collection of all attributes is returned.

    .EXAMPLE
    PS> $node =  nnode -NodeName "child-A"
    PS> $node | gattr -All -System

    Key         Value   System
    ---         -----   ------
    NodeName    child-A True
    Idx         0       True
    NextChildId 1       True

#>

# function Get-Attribute {
#     [CmdletBinding(DefaultParameterSetName="Single")]
#     [OutputType([PsCustomObject], ParameterSetName="Single")]
#     [OutputType([PsCustomObject], ParameterSetName="All")]

#     param (
#         [Parameter(ParameterSetName = 'Single')]
#         [Parameter(ParameterSetName = 'All')]
#         [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [hashtable] $Node,

#         [Parameter(ParameterSetName = 'Single')]
#         [Parameter(Mandatory = $false)] [string] $Key,

#         [Parameter(ParameterSetName = 'All')]
#         [switch] $All,

#         [Parameter(ParameterSetName = 'Single')]
#         [Parameter(ParameterSetName = 'All')]
#         [switch] $System
#     )

#     if ($All) { 
#         if ($System) {
#             foreach ($akey in $Node[$SA].Keys) 
#             { 
#                 [PSCustomObject] @{ Key = $akey; Value = $Node[$SA][$akey]; System = $true } | Write-Output ; 
#             }            
#         }
#         else {
#             foreach ($akey in $Node[$A].Keys) 
#             { 
#                 [PSCustomObject] @{ Key = $akey; Value = $Node[$A][$akey]; System = $false  } | Write-Output; 
#             }    
#         }
#     }
#     else { 
#         if ($System) {
#             if ($Node[$SA].ContainsKey($Key)) 
#             {
#                 [PSCustomObject] @{ Key = $Key; Value = $Node[$SA][$Key]; System = $true  } | Write-Output ;     
#             }
#         }
#         else {
#             if ($Node[$A].ContainsKey($Key)) 
#             {
#                 [PSCustomObject] @{ Key = $Key; Value = $Node[$A][$Key]; System = $false  } | Write-Output ; 
#             }
#         } 
#     }
# }
# Set-Alias -Name:gattr -Value:Get-Attribute
# Export-ModuleMember -Function:Get-Attribute
# Export-ModuleMember -Alias:gattr

<#
    .SYNOPSIS
    Get attribute value.

    .PARAMETER Node
    Source node.

    .PARAMETER Key
    Attribute key.

    .PARAMETER System
    Switch, if used, system attributes are searched for a key.

    .EXAMPLE
    PS> $node =  nnode -NodeName "child-A"
    PS> Set-AttributeValue -Node:$node -Key:"Normal" -Value:"I'm attr."
    PS> gattrv -N:$node -K:"Normal"

    I'm attr.

#>

# function Get-AttributeValue {
#     [CmdletBinding(DefaultParameterSetName="Default")]
#     [OutputType([System.Object], ParameterSetName="Default")]

#     param (
#         [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [hashtable] $Node,

#         [Parameter(Mandatory = $true)] [string] $Key,

#         [switch] $System
#     )

#     [PSCustomObject] $attr = $System ? (Get-Attribute -Node:$Node -Key:$Key -System) : (Get-Attribute -Node:$Node -Key:$Key);
#     if ($attr) { return $attr.Value; }
# }
# Set-Alias -Name:gattrv -Value:Get-AttributeValue
# Export-ModuleMember -Function:Get-AttributeValue
# Export-ModuleMember -Alias:gattrv

<#
    .SYNOPSIS
    Validates attribute.

    .PARAMETER Node
    Used in scenarios when we need to compare with other attributes in the node.

    .PARAMETER AttributeInfo
    [PSCustomObject] with Key, Value, System.

    .EXAMPLE
    PS> $node =  nnode -NodeName "child-A"
    PS> gattr -N:$node -A -S | Test-Attribute

    Key         Value   System
    ---         -----   ------
    NodeName    child-A True
    Idx         0       True
    NextChildId 1       True
    
#>
# function Test-Attribute {
#     [CmdletBinding(DefaultParameterSetName="Default")]
#     [OutputType([PSCustomObject], ParameterSetName="Default")]

#     param (
#         [Parameter(Mandatory = $false)] [hashtable] $Node,

#         [Parameter(Mandatory = $false, ValueFromPipeline = $true)] [PSCustomObject] $AttributeInfo
#     )

#     Process { 
#         if ( -not (
#                 ($AttributeInfo.Value -is [string]) -or 
#                 ($AttributeInfo.Value -is [int]) -or 
#                 ($AttributeInfo.Value -is [double]) -or 
#                 ($AttributeInfo.Value -is [bool]))) { throw "Attribute value type not allowed." }

#         if ($AttributeInfo.System) 
#         { 
#             if (-not $sysAttr.Contains([SysAttrKey]$AttributeInfo.Key)) { throw "System Attribute Key not allowed." } 

#             if ([SysAttrKey]::NodeName -eq [SysAttrKey]$AttributeInfo.Key) {
#                 if ($AttributeInfo.Value -match '^[0-9]') { throw "Incorrect NodeName value." };
#                 if ($AttributeInfo.Value.Contains($pdel)) { throw "Node name can't contain path delimiter." }
#             }
#         }
#         else {

#         }

#         $AttributeInfo | Write-Output;
#     }
# }
# Set-Alias -Name:tattr -Value:Test-Attribute
# Export-ModuleMember -Function:Test-Attribute
# Export-ModuleMember -Alias:tattr

<#
    .SYNOPSIS
    Creates AttributeInfo object.

    .PARAMETER Key

    .PARAMETER Value

    .PARAMETER System
    Switch on for system attributes.

    .EXAMPLE
    PS> nattr -K:"Price" -V:999.99 | Test-Attribute

    Key         Value   System
    ---         -----   ------
    Price       999,99  False

    
#>

# function New-Attribute {
#     [CmdletBinding(DefaultParameterSetName="Default")]
#     [OutputType([PSCustomObject], ParameterSetName="Default")]

#     param (
#         [Parameter(Mandatory = $true)] [string] $Key,

#         [Parameter(Mandatory = $true)] [object] $Value,

#         [switch] $System
#     )

#     return [PSCustomObject]@{ Key = $Key; Value = $Value; System = $System } ; 
# }
# Set-Alias -Name:nattr -Value:New-Attribute
# Export-ModuleMember -Function:New-Attribute
# Export-ModuleMember -Alias:nattr

<#
    .SYNOPSIS
    Sets node with key and value contained in AttributeInfo object.

    .PARAMETER Node

    .PARAMETER AttributeInfo

    .PARAMETER PassThru
    Sends AttributeInfo object to output stream.

    .EXAMPLE
    PS> $node = nnode -NodeName "child-A";
    PS> nattr -K:"Price" -V:999.99 | sattr -Node:$node -PassThru

    Key         Value   System
    ---         -----   ------
    Price       999,99  False

#>

function Set-Attribute {
    [CmdletBinding()]
    [OutputType([DataNode.Core.DataNode])]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [DataNode.Core.DataNode] $DataNode,

        [Parameter(ParameterSetName = 'KeyAttribute')]
        [Parameter(Mandatory = $false)] [string] $Key,

        [Parameter(ParameterSetName = 'IndexAttribute')]
        [Parameter(Mandatory = $false)] [int] $Index,

        [Parameter(ParameterSetName = 'KeyAttribute')]
        [Parameter(ParameterSetName = 'IndexAttribute')]
        [Parameter(Mandatory = $false)] [string] $Attribute,

        [Parameter(ParameterSetName = 'KeyAttribute')]
        [Parameter(ParameterSetName = 'IndexAttribute')]
        [ValidateScript({ $_ -is [string] -or $_ -is [int] -or $_ -is [decimal] })]
        [Parameter(Mandatory = $false)] [object]$Value
    )

    Begin {
    }

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'KeyAttribute' {
                $attributes = $DataNode.GetOrCreate($Key);
                $attributes.Set($Attribute, $Value);
                break
            }            
            'IndexAttribute' {
                $attributes = $DataNode.GetOrCreate($Index);
                $attributes.Set($Attribute, $Value);
                break
            }
        }

        Write-Output $DataNode;
    }
}

Set-Alias -Name:sattr -Value:Set-Attribute
Export-ModuleMember -Function:Set-Attribute
Export-ModuleMember -Alias:sattr

<#
    .SYNOPSIS
    Combines New-Attribute, Test-Attribute and Set-Attribute.

    .PARAMETER Node

    .PARAMETER Key

    .PARAMETER Value

    .PARAMETER System

    .PARAMETER PassThru
    Sends AttributeInfo object to output stream.

    .EXAMPLE
    PS> $node = nnode -NodeName "child-A";
    PS> sattrv -N:$node -K:"Price" -V:999.99 -PassThru

    Key         Value   System
    ---         -----   ------
    Price       999,99  False

#>
# function Set-AttributeValue {
#     [CmdletBinding(DefaultParameterSetName="Default")]
#     [OutputType([PSCustomObject], ParameterSetName="Default")]

#     param (
#         [Parameter(Mandatory = $true)] [hashtable] $Node,

#         [Parameter(Mandatory = $true)] [string] $Key,

#         [Parameter(Mandatory = $true)] [object] $Value,

#         [switch] $System,

#         [switch] $PassThru
#     )

#     New-Attribute -Key:$Key -Value:$Value -System:$System |
#     Test-Attribute -Node:$Node |
#     Set-Attribute -Node:$Node -PassThru:$PassThru;
# }
# Set-Alias -Name:sattrv -Value:Set-AttributeValue
# Export-ModuleMember -Function:Set-AttributeValue
# Export-ModuleMember -Alias:sattrv

<#
    .SYNOPSIS
    Removes attribute(s) from node. Attribute to remove can be passed as AttributeInfo objects in pipe or by Key.
    System attributes can't be removed.

    .PARAMETER Node

    .PARAMETER AttributeInfo

    .PARAMETER Key

    .PARAMETER PassThru
    Pass removed AttributeInfo object(s) to output stream.

    .EXAMPLE
    PS> $node = nnode -NodeName "child-A";
    PS> nattr -K:"Price" -V:999.99 | sattr -Node:$node;
    PS> #   remove all attributes from node with PassThru
    PS> gattr -N:$node -A | rattr -N:$node -P

    Key         Value   System
    ---         -----   ------
    Price       999,99  False

    .EXAMPLE
    PS> $node = nnode -NodeName "child-A";
    PS> nattr -K:"Price" -V:999.99 | sattr -Node:$node;
    PS> #   remove selected attribute from node with PassThru
    PS>  rattr -N:$node -K:"Price" -P

    Key         Value   System
    ---         -----   ------
    Price       999,99  False

#>
# function Remove-Attribute {
#     [CmdletBinding(DefaultParameterSetName="Pipe")]
#     [OutputType([PSCustomObject], ParameterSetName="Pipe")]
#     [OutputType([PSCustomObject], ParameterSetName="Key")]

#     param (
#         [Parameter(ParameterSetName = 'Pipe')]
#         [Parameter(ParameterSetName = 'Key')]
#         [Parameter(Mandatory = $true)] [hashtable] $Node,

#         [Parameter(ParameterSetName = 'Pipe')]
#         [Parameter(Mandatory = $false, ValueFromPipeline = $true)] [PSCustomObject] $AttributeInfo,

#         [Parameter(ParameterSetName = 'Key')]
#         [Parameter(Mandatory = $false)] [string] $Key,

#         [Parameter(ParameterSetName = 'Pipe')]
#         [Parameter(ParameterSetName = 'Key')]
#         [switch] $PassThru
#     )

#     Begin {
#         [PSCustomObject[]] $toRemove = @();

#         if ($Key) {
#             $toRemove += (Get-Attribute -Node:$Node -Key:$Key);
#         }
#     }

#     Process
#     { 
#         if ($AttributeInfo) {
#             $toRemove += $AttributeInfo;            
#         }
#     }

#     End {
#         foreach ($ai in $toRemove) {
#             if ($ai.System) {
#                 Write-Error "Removing system attributes not allowed.";
#                 # $Node[$SA].Remove($AttributeInfo.Key); 
#             }
#             else {
#                 $Node[$A].Remove($ai.Key); 
#             }

#             if ($PassThru) { $ai | Write-Output; }            
#         }
#     }
# }
# Set-Alias -Name:rattr -Value:Remove-Attribute
# Export-ModuleMember -Function:Remove-Attribute
# Export-ModuleMember -Alias:rattr

<#
    .SYNOPSIS
    Creates new node and sets initial system attributes.

    .PARAMETER NodeName

    .EXAMPLE
    PS> $node = nnode -NodeName "child-A";
    PS> gattr -N:$node -A -S

    Key         Value   System
    ---         -----   ------
    NodeName    child-A True
    Idx         0       True
    NextChildId 1       True

#>
function New-DataNode {
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([hashtable], ParameterSetName="Default")]

    param (
        [string] $NodeName
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
