Import-Module .\InteractiveMenu\InteractiveMenu.psd1

# Multiple selection items
$multiMenuOptions = @(
    Get-InteractiveMultiMenuOption `
        -Item "Sample option deselected" `
        -Label "Sample option deselected" `
        -Order 0 `
        -Info "This is some info" `
        -Url "https://google.com"
    Get-InteractiveMultiMenuOption `
        -Item "Sample option selected" `
        -Label "Sample option selected" `
        -Order 1 `
        -Info "This is some info" `
        -Url "https://google.com" `
        -Selected
    Get-InteractiveMultiMenuOption `
        -Item "Sample option mandatory" `
        -Label "Sample option mandatory" `
        -Order 3 `
        -Info "This is some info" `
        -Url "https://google.com" `
        -Selected `
        -Readonly
    Get-InteractiveMultiMenuOption `
        -Item "Sample option unavailable" `
        -Label "Sample option unavailable" `
        -Order 4 `
        -Info "This is some info" `
        -Url "https://google.com" `
        -Readonly
    Get-InteractiveMultiMenuOption `
        -Item "Sample option without info" `
        -Label "Sample option without info" `
        -Order 5 `
        -Url "https://google.com"
    Get-InteractiveMultiMenuOption `
        -Item "Sample option without URL" `
        -Label "Sample option without URL" `
        -Order 6 `
        -Info "This is some info"
)

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

$header = "Demo of the multi-selection menu"

$selectedOptions = Get-InteractiveMenuUserSelection -Header $header -Items $multiMenuOptions -Options $options

$selectedOptions | Format-List

Remove-Module InteractiveMenu