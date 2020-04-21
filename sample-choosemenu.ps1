Import-Module .\InteractiveMenu\InteractiveMenu.psd1

# Choose menu answers
$answers = @(
    Get-InteractiveChooseMenuOption `
        -Label "Option 1" `
        -Value "1" `
        -Info "This is the info for option 1"
    Get-InteractiveChooseMenuOption `
        -Label "Option 2" `
        -Value "2" `
        -Info "This is the info for option 2"
)

$options = @{
    MenuInfoColor = [ConsoleColor]::DarkYellow;
    QuestionColor = [ConsoleColor]::Magenta;
    HelpColor = [ConsoleColor]::Cyan;
    ErrorColor = [ConsoleColor]::DarkRed;
    HighlightColor = [ConsoleColor]::DarkGreen;
    OptionSeperator = "      ";
}

$answer = Get-InteractiveMenuChooseUserSelection -Question "Sample Question" -Answers $answers -Options $options

Write-Host "Answer: $answer"

Remove-Module InteractiveMenu