# Powershell Interactive Menu

> Note: this project is in development now. New versions will be available soon

## Description

The scope of this module is to provide an interactive way to select items from a list in powershell.

[![asciicast](https://asciinema.org/a/xctv6HbCj7A3jQ0ppkBN0hjdE.svg)](https://asciinema.org/a/xctv6HbCj7A3jQ0ppkBN0hjdE)

## Install

```powershell
Install-Module -Name InteractiveMenu
```

Or manual download from [PowershellGallery](https://www.powershellgallery.com/packages/InteractiveMenu)

## Usage

Usage can be found in the [test.ps1](https://github.com/bibistroc/powershell-interactive-menu/blob/master/test.ps1) file:

```powershell
Import-Module InteractiveMenu

# define the list of options (more items can be added)
$multiMenuOptions = @(
    Get-InteractiveMultiMenuOption `
        -Item "Sample option deselected" `
        -Label "Sample option deselected" `
        -Order 0 `
        -Info "This is some info" `
        -Url "https://google.com"
)

# define the text that you want to describe de selection
$header = "Demo of the multi-selection menu"

# trigger the menu and get the user options
$selectedOptions = Get-InteractiveMenuUserSelection -Header $header -Items $multiMenuOptions

# print the selected options
$selectedOptions | Format-List
```