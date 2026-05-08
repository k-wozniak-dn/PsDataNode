

#region init
$script:ErrorActionPreference = 'Stop';
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
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Attribute] $Attribute,

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
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Attribute] $Attribute,

        [Parameter(Mandatory = $true, Position = 0)] 
        [DataNode.Core.Item] $Item,

        [Parameter(ParameterSetName = 'ByName')]
        [Alias('Name')]
        [Parameter(Mandatory = $false, Position = 1)] 
        [string] $AttributeName,

        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(Mandatory = $false, Position = 2)] 
        [ValidateScript({ $_ -is [string] -or $_ -is [int] -or $_ -is [decimal] })]        
        [object]$Value,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'ByName')]
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
            'ByName' {
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
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Attribute] $Attribute,

        [Parameter(Mandatory = $true, Position = 0)] 
        [DataNode.Core.Item] $Item,

        [Parameter(ParameterSetName = 'ByName')]
        [Alias('Name')]
        [Parameter(Mandatory = $false, Position = 1)] 
        [string] $AttributeName,

        [Parameter(ParameterSetName = 'ByName')]
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
            'ByName' {
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
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Attribute] $Attribute,

        [Parameter(Mandatory = $true, Position = 0)] 
        [DataNode.Core.Item] $Item,

        [Parameter(ParameterSetName = 'ByName')]
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
            'ByName' {
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
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([DataNode.Core.DataNode], ParameterSetName="Default")]

    param (
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Item] $Item
    )

    begin {
        $items = New-Object 'System.Collections.Generic.List[DataNode.Core.Item]'
    }
    
    process {
        if ($Item) {
            $items.Add($Item);
        }
    }

    end {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return [DataNode.Core.DataNode]::new($items);
                break
            }
        }        
    }
}
Set-Alias -Name:ndn -Value:New-DataNode
Export-ModuleMember -Function:New-DataNode
Export-ModuleMember -Alias:ndn

function Copy-DataNode {
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([DataNode.Core.DataNode], ParameterSetName="Default")]

    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [DataNode.Core.DataNode] $From
    )

    begin {
    }
    
    process {
    }

    end {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $From.Copy();
                break
            }
        }        
    }
}

Set-Alias -Name:cpdn -Value:Copy-DataNode
Export-ModuleMember -Function:Copy-DataNode
Export-ModuleMember -Alias:cpdn

function Get-dnItem {
    [CmdletBinding(DefaultParameterSetName='Default')]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('dn', 'Node')]
        [DataNode.Core.DataNode] $DataNode,

        [Parameter(Mandatory = $false, Position = 0)] [string[]] $Key,

        [switch] $CreateIfNotFound,

        [Parameter(ParameterSetName = 'All')]
        [switch] $All

        # [Alias('Hashtable', 'Hash')]
        # [switch] $AsHashtable = $false

    )

    Process
    { 
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                foreach ($k in $Key) 
                {
                    $item = ($false -eq $CreateIfNotFound) ? 
                        $DataNode.Get($k) : 
                        $DataNode.GetOrCreate($k);
                    $item | Write-Output;                    
                }
                break
            }
            'All' {
                $DataNode.GetAll() | Write-Output;
                break
            }
        }
    }
}

Set-Alias -Name:gdni -Value:Get-dnItem
Export-ModuleMember -Function:Get-dnItem
Export-ModuleMember -Alias:gdni

function Set-dnItem {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Item])]

    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Item] $Item,

        [Alias('dn', 'Node')]
        [Parameter(Mandatory = $true, Position = 0)] 
        [DataNode.Core.DataNode] $DataNode,

        [switch] $ExistingOnly
    )

    begin {
        $items = New-Object 'System.Collections.Generic.List[DataNode.Core.Item]'
    }
    process {
        if ($Item) {
            $items.Add($Item);
        }
    }
    end
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $DataNode.SetAll($items, $ExistingOnly);
                break
            }         
        }
    }
}
Set-Alias -Name:sdni -Value:Set-dnItem
Export-ModuleMember -Function:Set-dnItem
Export-ModuleMember -Alias:sdni

function Add-dnItem {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Item])]

    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Item] $Item,

        [Alias('dn', 'Node')]
        [Parameter(Mandatory = $true, Position = 0)] 
        [DataNode.Core.DataNode] $DataNode
    )

    begin {
        $items = New-Object 'System.Collections.Generic.List[DataNode.Core.Item]'
    }
    process {
        if ($Item) {
            $items.Add($Item);
        }
    }
    end
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $DataNode.AddAll($items);
                break
            }         
        }
    }
}

Set-Alias -Name:adni -Value:Add-dnItem
Export-ModuleMember -Function:Add-dnItem
Export-ModuleMember -Alias:adni

function Remove-dnItem {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Item])]

    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Item] $Item,

        [Alias('dn', 'Node')]
        [Parameter(Mandatory = $true, Position = 0)] 
        [DataNode.Core.DataNode] $DataNode,

        [Parameter(ParameterSetName = 'ByKey')]
        [Parameter(Mandatory = $false, Position = 1)] 
        [string[]] $Key
    )

    begin {
        $items = New-Object 'System.Collections.Generic.List[DataNode.Core.Item]'
    }
    process {
        if ($Item) {
            $items.Add($Item);
        }
    }
    end 
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                return $DataNode.RemoveAll($items);
                break
            }
            'ByKey' {
                return $DataNode.RemoveAll($Key);
                break
            }
        }
    }
}

Set-Alias -Name:rmdni -Value:Remove-dnItem
Export-ModuleMember -Function:Remove-dnItem
Export-ModuleMember -Alias:rmdni


#endregion

#region Index
function Set-dnIndex {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Item])]

    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Item] $Item
    )

    begin {
        $items = New-Object 'System.Collections.Generic.List[DataNode.Core.Item]';
    }
    process {
        if ($Item) {
            $items.Add($Item);
        }
    }
    end 
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                foreach($i in $items) {
                    $i.SetIndex() | Write-Output;
                }
                break;
            }
        }
    }
}

Set-Alias -Name:sdnx -Value:Set-dnIndex
Export-ModuleMember -Function:Set-dnIndex
Export-ModuleMember -Alias:sdnx

function Remove-dnIndex {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Item])]

    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Item] $Item
    )

    begin {
        $items = New-Object 'System.Collections.Generic.List[DataNode.Core.Item]';
    }
    process {
        if ($Item) {
            $items.Add($Item);
        }
    }
    end 
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                foreach($i in $items) {
                    $i.RemoveIndex() | Write-Output;
                }
                break;
            }
        }
    }
}

Set-Alias -Name:rmdnx -Value:Remove-dnIndex
Export-ModuleMember -Function:Remove-dnIndex
Export-ModuleMember -Alias:rmdnx

enum MoveToIndexOption {start; end; }
function Move-toDnIndex {
    [CmdletBinding(DefaultParameterSetName='Default')]
    [OutputType([DataNode.Core.Item])]

    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] 
        [DataNode.Core.Item] $Item,

        [Alias('Offset', 'Idx')]
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateScript({ $_ -is [string] -or $_ -is [int] ;})]
        [object] $IndexOffset
    )

    begin {
        $items = New-Object 'System.Collections.Generic.List[DataNode.Core.Item]';
    }
    process {
        if ($Item) {
            $items.Add($Item);
        }
    }
    end 
    {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                foreach($i in $items) {
                    if ($IndexOffset -is [int])
                    {
                        $i.Move($IndexOffset) | Write-Output;
                    }
                    elseif ($IndexOffset -is [string] -and [MoveToIndexOption]::start -eq [MoveToIndexOption]$IndexOffset) 
                    {
                        $i.MoveToStart() | Write-Output;
                    }
                    elseif ($IndexOffset -is [string] -and [MoveToIndexOption]::end -eq [MoveToIndexOption]$IndexOffset) 
                    {
                        $i.MoveToEnd() | Write-Output;
                    }
                }
                break;
            }
        }
    }
}

Set-Alias -Name:mvdnx -Value:Move-toDnIndex
Export-ModuleMember -Function:Move-toDnIndex
Export-ModuleMember -Alias:mvdnx

#endregion

#region export

function ConvertFrom-DnItem {
    [CmdletBinding(DefaultParameterSetName="Default")]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] 
        [ValidateScript({ $_ -is [DataNode.Core.Item] ;})]
        [object] $DnObject,

        [Parameter(ParameterSetName = 'Dictionary')]
        [Alias('AsDct', 'Dct')]
        [switch] $AsDictionary,

        [Parameter(ParameterSetName = 'Hashtable')]
        [Alias('Hash')]
        [switch] $AsHashtable
    )

    begin {
    }
    
    process {
        If ($DnObject) {
            switch ($PSCmdlet.ParameterSetName) {
                'Dictionary' {
                    $item = [DataNode.Core.Item]$DnObject;
                    return $item.ToDictionary();                            
                    break;
                }
                'Hashtable' {
                    $item = [DataNode.Core.Item]$DnObject;
                    $hash = @{};
                    foreach ($attr in $item.GetAll()) {
                        $hash[$attr.Name] = [DataNode.Core.DnValue]::ToObjectValue($attr.Value);
                    }
                    return $hash;
                    break;
                }
            }                 
        }
    }
}

Set-Alias -Name:cvdni -Value:ConvertFrom-DnItem
Export-ModuleMember -Function:ConvertFrom-DnItem
Export-ModuleMember -Alias:cvdni

function ConvertFrom-Dn {
    [CmdletBinding(DefaultParameterSetName="Default")]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] 
        [ValidateScript({ $_ -is [DataNode.Core.DataNode] ;})]
        [object] $DnObject,

        [Parameter(ParameterSetName = 'Dictionary')]
        [Alias('AsDct', 'Dct')]
        [switch] $AsDictionary,

        [Parameter(ParameterSetName = 'Hashtable')]
        [Alias('Hash')]
        [switch] $AsHashtable
    )

    begin {
    }
    
    process {
        If ($DnObject) {
            switch ($PSCmdlet.ParameterSetName) {
                'Dictionary' {
                    if ($DnObject -is [DataNode.Core.DataNode]) {
                        $dn = [DataNode.Core.DataNode]$DnObject;
                        return $dn.ToDictionary();                            
                    }
                    break;
                }
                'Hashtable' {
                    $dn = [DataNode.Core.DataNode]$DnObject;
                    $hash = @{};
                    foreach ($item in $dn.GetAll()) {
                        $itemHash = @{};
                        foreach ($attr in $item.GetAll()) {
                            $itemHash[$attr.Name] = [DataNode.Core.DnValue]::ToObjectValue($attr.Value);
                        }                                
                        $hash[$item.Key] = $itemHash;
                    }
                    return $hash;
                    break;
                }
            }                 
        }
    }
}

Set-Alias -Name:cvdn -Value:ConvertFrom-Dn
Export-ModuleMember -Function:ConvertFrom-Dn
Export-ModuleMember -Alias:cvdn

function ConvertTo-DnItem {
    [CmdletBinding(DefaultParameterSetName="Default")]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] 
        [ValidateScript({ 
            $_ -is [hashtable] -or 
            $_ -is [System.Collections.Generic.Dictionary[string, object]] -or
            $_ -is [string] ;})]
        [object] $ImportObject,

        [Parameter(ParameterSetName = 'Dictionary')]
        [Alias('AsDct', 'Dct')]
        [switch] $FromDictionary,

        [Parameter(ParameterSetName = 'Hashtable')]
        [Alias('Hash')]
        [switch] $FromHashtable
    )

    begin {
    }
    
    process {
        If ($ImportObject) {
            switch ($PSCmdlet.ParameterSetName) {
                'Dictionary' {
                    $import = [System.Collections.Generic.Dictionary[string, object]]$ImportObject;
                    return [DataNode.Core.Item]::FromDictionary($import);
                    break;
                }
                'Hashtable' {
                    $itemHash = [hashtable]$ImportObject;
                    $item = [System.Collections.Generic.Dictionary[string, object]]::new();
                    foreach ($name in $itemHash.Keys) {
                        $item[$name] = $itemHash[$name];
                    }
                    return [DataNode.Core.Item]::FromDictionary($item);
                    break;
                }
            }                 
        }
    }
}

Set-Alias -Name:cv2dni -Value:ConvertTo-DnItem
Export-ModuleMember -Function:ConvertTo-DnItem
Export-ModuleMember -Alias:cv2dni

function ConvertTo-Dn {
    [CmdletBinding(DefaultParameterSetName="Default")]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] 
        [ValidateScript({ 
            $_ -is [hashtable] -or 
            $_ -is [System.Collections.Generic.Dictionary[string, System.Collections.Generic.Dictionary[string, object]]] -or
            $_ -is [string] ;})]
        [object] $ImportObject,

        [Parameter(ParameterSetName = 'Dictionary')]
        [Alias('AsDct', 'Dct')]
        [switch] $FromDictionary,

        [Parameter(ParameterSetName = 'Hashtable')]
        [Alias('Hash')]
        [switch] $FromHashtable
    )

    begin {
    }
    
    process {
        If ($ImportObject) {
            switch ($PSCmdlet.ParameterSetName) {
                'Dictionary' {
                    $import = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.Dictionary[string, object]]]$ImportObject;
                    return [DataNode.Core.DataNode]::FromDictionary($import);
                    break;
                }
                'Hashtable' {
                    $importHash = [hashtable]$ImportObject;
                    $dct = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.Dictionary[string, object]]]::new();

                    foreach($key in $importHash.Keys) {
                        [hashtable]$itemHash = $importHash[$key];
                        $item = [System.Collections.Generic.Dictionary[string, object]]::new();
                        foreach($name in $itemHash.Keys) {
                            $item[$name] = $itemHash[$name];
                        }
                        $dct[$key] = $item;
                    }

                    return [DataNode.Core.DataNode]::FromDictionary($dct);
                    break;
                }
            }                 
        }
    }
}

Set-Alias -Name:cv2dn -Value:ConvertTo-Dn
Export-ModuleMember -Function:ConvertTo-Dn
Export-ModuleMember -Alias:cv2dn


#endregion
