shelljump
=========
```
A powershell script containing commands to navigate your filesystem quickly a-la bookmarks.
Add to your PS profile with
  . ~\Documents\WindowsPowerShell\shelljump\shelljump.ps1

Inspired by "Quickly navigate your filesystem from the command-line"
http://tinyurl.com/nx6wzvq

Script allowing for bookmarking of folders under aliases and the
capability to jump to them, persisting between shell sessions.

Jump and unmark commands have tab completion (cycling only), with
fallback to normal tab completion on failure to match commands.

Commands (aliased):
	jump (name)     | Jump to a previously bookmarked folder.
	jumps or marks  | List all existing bookmarks.
	mark (name)     | Bookmarks current directory as a given name.
	unmark (name)   | Removes named bookmark.
	
Underlying functions:
	New-Bookmark
	Remove-Bookmark
	Invoke-Bookmark
	Write-Bookmarks
	Read-Bookmarks (Triggered on script load)
	Get-Bookmarks
	TabExpansion (Renaming default to TabExpansionBackupJump which
				  gets called as a fallback.)

Storage:
  Bookmarks are serialized to a Jumps.json file in the powershell
  profile's folder. (Usually My Documents\WindowsPowerShell\)
  Saves are atomic and triggered on add and remove
  , the last version being saved as Jumps.json.prev.

Example:
	C:\> cd '.\Program Files\Sublime Text 2'
	C:\Program Files\Sublime Text 2> mark st2
	C:\Program Files\Sublime Text 2> cd \
	C:\> jump st2
	C:\Program Files\Sublime Text 2> marks
	st2        -> C:\Program Files\Sublime Text 2
	C:\Program Files\Sublime Text 2> unmark st2
```