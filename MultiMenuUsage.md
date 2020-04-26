# Interactive Multi Menu

## Demo
[![asciicast](https://asciinema.org/a/IbuA6vFBCcN9CQImZYLsHIXUu.svg)](https://asciinema.org/a/IbuA6vFBCcN9CQImZYLsHIXUu)

## Install

```powershell
Install-Module -Name InteractiveMenu
```

## Prerequisites

This module only works in Powershell version 5.0 and up.

## Usage

Sample code can be found [here](sample-multimenu.ps1)

### Using classes

```powershell
# Import the module
using module InteractiveMenu

# Define the items for the menu
# Note: the url and info are optional
$menuItems = @(
    [InteractiveMultiMenuItem]::new("option1", "First Option", $true, 0, $false, "First option info", "https://example.com/")
    [InteractiveMultiMenuItem]::new("Option 2", "Second Option", $true, 1, $false, "Second option info", "https://example.com/")
)

# Define the header of the menu
$header = "Choose your options"

# Instantiate new menu object
$menu = [InteractiveMultiMenu]::new($header, $menuItems);

# [Optional] You can change the colors and the symbols
$options = @{
    HeaderColor = [ConsoleColor]::Magenta;
    HelpColor = [ConsoleColor]::Cyan;
    CurrentItemColor = [ConsoleColor]::DarkGreen;
    LinkColor = [ConsoleColor]::DarkCyan;
    CurrentItemLinkColor = [ConsoleColor]::Black;
    MenuDeselected = "[ ]";
    MenuSelected = "[x]";
    MenuCannotSelect = "[/]";
    MenuCannotDeselect = "[!]";
    MenuInfoColor = [ConsoleColor]::DarkYellow;
    MenuErrorColor = [ConsoleColor]::DarkRed;
}
$menu.SetOptions($options)

# Trigger the menu and receive the user selections
$selectedItems = $menu.GetSelections()

foreach ($item in $selectedItem) {
    Write-Host $item
}
```

### Using functions

```powershell
# Import the module
Import-Module InteractiveMenu

# Define the items for the menu
# Note: the url, info, selected and readonly parameters are optional
$menuItems = @(
    Get-InteractiveMultiMenuOption `
        -Item "option1" `
        -Label "First Option" `
        -Order 0 `
        -Info "First option info" `
        -Url "https://example.com"
    Get-InteractiveMultiMenuOption `
        -Item "option2" `
        -Label "Second Option" `
        -Order 1 `
        -Info "Second option info" `
        -Url "https://example.com" `
        -Selected `
        -Readonly
)

# [Optional] You can change the colors and the symbols
$options = @{
    HeaderColor = [ConsoleColor]::Magenta;
    HelpColor = [ConsoleColor]::Cyan;
    CurrentItemColor = [ConsoleColor]::DarkGreen;
    LinkColor = [ConsoleColor]::DarkCyan;
    CurrentItemLinkColor = [ConsoleColor]::Black;
    MenuDeselected = "[ ]";
    MenuSelected = "[x]";
    MenuCannotSelect = "[/]";
    MenuCannotDeselect = "[!]";
    MenuInfoColor = [ConsoleColor]::DarkYellow;
    MenuErrorColor = [ConsoleColor]::DarkRed;
}

# Define the header of the menu
$header = "Choose your options"

# Trigger the menu and receive the user selections
# Note: the options parameter is optional
$selectedOptions = Get-InteractiveMenuUserSelection -Header $header -Items $menuItems -Options $options
```

## Refferences

### Class `InteractiveMultiMenuItem`

#### Constructors
* `InteractiveMultiMenuItem([object]$itemInfo, [string]$label, [int]$order)`
* `InteractiveMultiMenuItem([object]$itemInfo, [string]$label, [bool]$selected, [int]$order)`
* `InteractiveMultiMenuItem([object]$itemInfo, [string]$label, [bool]$selected, [int]$order, [bool]$readonly)`
* `InteractiveMultiMenuItem([object]$itemInfo, [string]$label, [bool]$selected, [int]$order, [bool]$readonly, [string]$info)`
* `InteractiveMultiMenuItem([object]$itemInfo, [string]$label, [bool]$selected, [int]$order, [bool]$readonly, [string]$info, [string]$url)`

#### Fields
* **[Mandatory]** `[object]$ItemInfo` - The item that you want returned if the user selects it
* **[Mandatory]** `[string]$Label` - The text that you want to show for your option
* **[Mandatory]** `[int]$Order` - The order of the item in the list. You can have multiple items on the same order. The script will order them.
* **[Optional]** `[bool]$Selected` - If the option is selected or not by default. Possible values: `$true` or `$false`
* **[Optional]** `[bool]$Readonly` - If the option is readonly (cannot be changed). Possible values: `$true` or `$false`
* **[Optional]** `[string]$Info` - The information about the item. This information is visible if the user press `I`.
* **[Optional]** `[string]$Url` - The URL of the item. A browser window will open on this URL if the user press `O`.

### Class `InteractiveMultiMenu`

#### Constructors
* `InteractiveMultiMenu([string]$header, [InteractiveMultiMenuItem[]]$items)`

#### Fields
* **[Mandatory]** `[string]$header` - The text that you want to display above the menu
* **[Mandatory]** `[InteractiveMultiMenuItem[]]$items` - The list of items to display in the menu

#### Methods
* `[object[]] GetSelections()` - Execute this method to trigger the menu and get the objects that the user selected
* `[void] SetOptions([hashtable]$options)` - Execute this method to alter the options of the menu (more details in the [Options](#Options) section)

## Options
* `HeaderColor` - Color of the header. Default: `[ConsoleColor]::Magenta;`
* `HelpColor` - Color of the help items. Default: `[ConsoleColor]::Cyan;`
* `CurrentItemColor` - Color of the current selected item. Default: `[ConsoleColor]::DarkGreen;`
* `LinkColor` - Color of the links. Default: `[ConsoleColor]::DarkCyan;`
* `CurrentItemLinkColor` - Color of the current selected item link. Default: `[ConsoleColor]::Black;`
* `MenuDeselected` - Sympol for unselected item. Default: `"[ ]";`
* `MenuSelected` - Symbol for selected item. Default: `"[x]";`
* `MenuCannotSelect` - Symbol for the item that cannot be selected. Default: `"[/]";`
* `MenuCannotDeselect` - Sympol for the item that cannot be deselected. Default: `"[!]";`
* `MenuInfoColor` - Color of the item information. Default: `[ConsoleColor]::DarkYellow;`
* `MenuErrorColor` - Color of the errors. Default: `[ConsoleColor]::DarkRed;`