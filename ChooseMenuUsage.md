# Interactive Choose Menu

## Demo

[![asciicast](https://asciinema.org/a/wdIQTAFPqnsu36RECXv8MAXrH.svg)](https://asciinema.org/a/wdIQTAFPqnsu36RECXv8MAXrH)

## Install

```powershell
Install-Module -Name InteractiveMenu
```

## Prerequisites

This module only works in Powershell version 5.0 and up.

## Usage

Sample code can be found [here](sample-choosemenu)

### Using classes

```powershell
# Import the module
using module InteractiveMenu

# Define the items for the menu
$answerItems = @(
    [InteractiveMenuChooseMenuItem]::new("I choose good", "good", "Good info"),
    [InteractiveMenuChooseMenuItem]::new("I choose bad", "bad", "Bad info")
);

# Define the question of the menu
$question = "Choos between good and bad"

# Instantiate new menu object
$menu = [InteractiveMenuChooseMenu]::new($question, $answerItems);

# [Optional] You can change the colors and the separator
$options = @{
    MenuInfoColor = [ConsoleColor]::DarkYellow
    QuestionColor = [ConsoleColor]::Magenta
    HelpColor = [ConsoleColor]::Cyan
    ErrorColor = [ConsoleColor]::DarkRed
    HighlightColor = [ConsoleColor]::DarkGreen
    OptionSeperator = "      "
}
$menu.SetOptions($options)

# Trigger the menu and receive the user answer
$answer = $menu.GetAnswer()

Write-Host "The user answered: $answer"
```

### Using functions

```powershell
# Import the module
Import-Module InteractiveMenu

# Define the items for the menu
$answerItems = @(
    Get-InteractiveChooseMenuOption `
        -Label "I choose good" `
        -Value "good" `
        -Info "Good info"
    Get-InteractiveChooseMenuOption `
        -Label "I choose bad" `
        -Value "bad" `
        -Info "Bad info"
)

# [Optional] You can change the colors and the symbols
$options = @{
    MenuInfoColor = [ConsoleColor]::DarkYellow
    QuestionColor = [ConsoleColor]::Magenta
    HelpColor = [ConsoleColor]::Cyan
    ErrorColor = [ConsoleColor]::DarkRed
    HighlightColor = [ConsoleColor]::DarkGreen
    OptionSeperator = "      "
}

# Define the question of the menu
$question = "Choos between good and bad"

# Trigger the menu and receive the user answer
# Note: the options parameter is optional
$answer = Get-InteractiveMenuChooseUserSelection -Question $question -Answers $answerItems -Options $options
```

## Refferences

### Class `InteractiveMenuChooseMenuItem`

#### Constructors
* `InteractiveMenuChooseMenuItem([string]$label, [string]$value, [string]$info)`

#### Fields
* **[Mandatory]** `[string]$Label` - The text that you want to show for your option
* **[Mandatory]** `[string]$Value` - The value that you want returned if the user selects it
* **[Mandatory]** `[string]$Info` - The information about the option. This information is displayed under the options

### Class `InteractiveMenuChooseMenu`

#### Constructors
* `InteractiveMenuChooseMenu([string]$question, [InteractiveMenuChooseMenuItem[]]$options)`

#### Fields
* **[Mandatory]** `[string]$question` - The question that you want to show above the options
* **[Mandatory]** `[InteractiveMenuChooseMenuItem[]]$options` - The list of answers to display in the menu

#### Methods
* `[string] GetAnswer()` - Execute this method to trigger the menu and get the answer that the user selected
* `[void] SetOptions([hashtable]$options)` - Execute this method to alter the options of the menu (more details in the [Options](#Options) section)

## Options
* `MenuInfoColor` - Color of the item information. Default: `[ConsoleColor]::DarkYellow`
* `QuestionColor` - Color of the question text. Default: `[ConsoleColor]::Magenta`
* `HelpColor` - Color of the help items. Default: `[ConsoleColor]::Cyan`
* `ErrorColor` - Color of the errors. Default: `[ConsoleColor]::DarkRed`
* `HighlightColor` - Color of the current selected item. Default: `[ConsoleColor]::DarkGreen`
* `OptionSeperator` - The separator between the answers. Default: "<kbd>space</kbd><kbd>space</kbd><kbd>space</kbd><kbd>space</kbd><kbd>space</kbd><kbd>space</kbd>" (6 spaces)
