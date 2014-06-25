<#
	https://github.com/kjerk/shelljump
	
	Commands (aliased):
		jump (name)     | Jump to a previously bookmarked folder.
		jumps or marks  | List all existing bookmarks.
		mark (name)     | Bookmarks current directory as a given name.
		unmark (name)   | Removes named bookmark.
		
	Example:
		C:\> cd '.\Program Files\Sublime Text 2'
		C:\Program Files\Sublime Text 2> mark st2
		C:\Program Files\Sublime Text 2> cd \
		C:\> jump st2
		C:\Program Files\Sublime Text 2> marks
		st2        -> C:\Program Files\Sublime Text 2
		C:\Program Files\Sublime Text 2> unmark st2
#>

[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | Out-Null

function New-Bookmark
{
	[CmdletBinding()]
	Param( 
		[Parameter(Mandatory=$true, Position=1)]
		[String]$newName
	)
	
	if( Check-BookmarksTimestamp -eq $true )
	{
		if(-not $global:bookmarks.ContainsKey($newName))
		{
			if($global:bookmarks.ContainsValue($PWD.ToString()))
			{
				"Warning: current path already bookmarked under different key."
			}

			$global:bookmarks.Add($newName, $PWD.ToString());
			
			Write-Bookmarks
		}
		else
		{
			"Key '$newName' already exists in bookmarks.";
		}
	}
	else
	{
		"Bookmarks on disk newer than loaded bookmarks. (Desynced)"
		"Please refresh them with Read-Bookmarks, or overwrite with Write-Bookmarks."
	}
}

function Remove-Bookmark
{
	[CmdletBinding()]
	Param( 
		[Parameter(Mandatory=$true, Position=1)]
		[String]$name
	)
	
	if( Check-BookmarksTimestamp -eq $true )
	{
		if($global:bookmarks.ContainsKey($name))
		{
			$global:bookmarks.Remove($name)  | Out-Null;
			Write-Bookmarks
		}
		else
		{
			"No key with value '$name' found."
		}
	}
	else
	{
		"Bookmarks on disk newer than loaded bookmarks. (Desynced)"
		"Please refresh them with Read-Bookmarks, or overwrite with Write-Bookmarks."
	}
}

function Read-Bookmarks
{
	$fPath = "$([System.IO.Path]::GetDirectoryName($profile))\Jumps.json";
	
	if([System.IO.File]::Exists($fPath))
	{
		$Global:JumpFileTime = (Get-Item "$([System.IO.Path]::GetDirectoryName($profile))\Jumps.json").LastWriteTime;
		if(Test-Path $fPath)
		{
			$global:bookmarks = @{};
			$ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
			$global:bookmarks = $ser.DeserializeObject((Get-Content $fPath))
		}
		else
		{
			$global:bookmarks = @{};
		}
	}
	else
	{
		$global:bookmarks = @{};
	}
}

function Check-BookmarksTimestamp
{
	$bPath = "$([System.IO.Path]::GetDirectoryName($profile))\Jumps.json"
	
	if(Test-Path $bPath)
	{
		$fDate = (Get-Item "$([System.IO.Path]::GetDirectoryName($profile))\Jumps.json").LastWriteTime;
		
		if($fDate -gt $Global:JumpFileTime)
		{
			return $false;
		}
	}
	
	return $true;
}

function Write-Bookmarks
{
	$profPath = [System.IO.Path]::GetDirectoryName($profile);
	$newPath = "$profPath\Jumps.json";
	$oldPath = "$profPath\Jumps.json.prev";
	
	if(Test-Path $oldPath) { 
		del "$oldPath"
	}
	
	if(Test-Path $newPath) {
		ren "$newPath" "$oldPath"
	}
	
	ConvertTo-Json $global:bookmarks | Out-File $newPath
	
	$Global:JumpFileTime = (Get-Item $newPath).LastWriteTime;
}

function Invoke-Bookmark
{
	[CmdletBinding()]
	Param( 
		[Parameter(Mandatory=$true, Position=1)]
		[String]$jumpcat = '.'
	)
	
	if($global:bookmarks.ContainsKey($jumpcat))
	{
		cd $global:bookmarks[$jumpcat].ToString();
	}
	else
	{
		"Unknown jump target."
		"Type: 'jumps' to get a list of available bookmarks."
	}
}

function Get-Bookmarks
{
	$en = $global:bookmarks.GetEnumerator();

	while($en.MoveNext())
	{
		"$($en.Key.PadRight(10)) -> $($en.Value)"
	}
}

Set-Alias jump   Invoke-Bookmark
Set-Alias jumps  Get-Bookmarks
Set-Alias marks  Get-Bookmarks
Set-Alias mark   New-Bookmark
Set-Alias unmark Remove-Bookmark

#Load bookmarks from previous session.
Read-Bookmarks

# Tab Expansion override compatibility, comment out these two
# blocks to leave tab completion alone.
if (Test-Path Function:\TabExpansion)
{
	Rename-Item Function:\TabExpansion TabExpansionBackupJump
}

function TabExpansion([string] $line, [string] $lastword)
{
	if( $line.StartsWith("jump ") -or $line.StartsWith("unmark ") )
	{
		return [string[]]$Global:bookmarks.Keys;
	}
	else
	{ # Fall back to the tab completion that was in place.
		if (Test-Path Function:\TabExpansionBackupJump)
		{
			TabExpansionBackupJump $line $lastword
		}
		else
		{
			return $null;
		}
	}
}