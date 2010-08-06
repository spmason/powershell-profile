My PowerShell Profile
===========

This is my personal powershell profile that I clone between various Windows machines I work on

** Important: Copy "environment.example.ps1" to "example.ps1" and edit the paths inside before use **

The profile imports posh-git and posh-svn to give auto-complete etc for working copies & clones of those repos

The profile also ensures that ssh-agent is running so you avoid having to type in your password every time you push/pull (ssh should be in your PATH for this to work)

I also add a few useful commands:
* gs -> "git status"
* n [path] -> "notepad"
* sudo [name] -> launch process as Administrator (in new window)
* hosts -> edit hosts file in notepad (will prompt for admin approval)
* dev -> jump to "Development" directory where you checkout your projects - tab-completion is provided for the folders under this dir
* dropbox -> jump to dropbox
* start-mongo -> Run MongoDb instance (need to configure this in environment.ps1)

Installation (Using git/powershell)
--------

1. cd ~\Documents
1. git clone git://github.com/spmason/powershell-profile.git WindowsPowerShell
1. cd WindowsPowerShell
1. git submodule init
1. git submodule update
1. cp environment.example.ps1 environment.ps1
1. notepad environment.ps1

Edit & save the file & restart the powershell console