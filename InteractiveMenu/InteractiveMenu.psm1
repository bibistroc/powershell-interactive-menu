#Requires -Version 5

class InteractiveMultiMenuItem {
    [ValidateNotNullOrEmpty()][object]$ItemInfo
    [ValidateNotNullOrEmpty()][string]$Label
    [ValidateNotNullOrEmpty()][bool]$Selected
    [ValidateNotNullOrEmpty()][int]$Order
    [bool]$Readonly
    [string]$Info
    [string]$Url

    InteractiveMultiMenuItem([object]$itemInfo, [string]$label, [int]$order) {
        $this.Init($itemInfo, $label, $false, $order, $null, $null, $null);
    }

    InteractiveMultiMenuItem([object]$itemInfo, [string]$label, [bool]$selected, [int]$order) {
        $this.Init($itemInfo, $label, $selected, $order, $null, $null, $null);
    }

    InteractiveMultiMenuItem([object]$itemInfo, [string]$label, [bool]$selected, [int]$order, [bool]$readonly) {
        $this.Init($itemInfo, $label, $selected, $order, $readonly, $null, $null);
    }

    InteractiveMultiMenuItem([object]$itemInfo, [string]$label, [bool]$selected, [int]$order, [bool]$readonly, [string]$info) {
        $this.Init($itemInfo, $label, $selected, $order, $readonly, $info, $null);
    }

    InteractiveMultiMenuItem([object]$itemInfo, [string]$label, [bool]$selected, [int]$order, [bool]$readonly, [string]$info, [string]$url) {
        $this.Init($itemInfo, $label, $selected, $order, $readonly, $info, $url);
    }

    hidden Init([object]$itemInfo, [string]$label, [bool]$selected, [int]$order, [bool]$readonly, [string]$info, [string]$url) {
        $this.ItemInfo = $itemInfo
        $this.Label = $label
        $this.Selected = $selected
        $this.Order = $order
        $this.Readonly = $readonly
        $this.Info = $info
        $this.Url = $url
    }
}

class InteractiveMultiMenu {
    [ValidateNotNullOrEmpty()][string]$Header
    [ValidateNotNullOrEmpty()][InteractiveMultiMenuItem[]]$Items

    [ValidateNotNullOrEmpty()][ConsoleColor]$HeaderColor = [ConsoleColor]::Magenta
    [ValidateNotNullOrEmpty()][ConsoleColor]$HelpColor = [ConsoleColor]::Cyan
    [ValidateNotNullOrEmpty()][ConsoleColor]$CurrentItemColor = [ConsoleColor]::DarkGreen
    [ValidateNotNullOrEmpty()][ConsoleColor]$LinkColor = [ConsoleColor]::DarkCyan
    [ValidateNotNullOrEmpty()][ConsoleColor]$CurrentItemLinkColor = [ConsoleColor]::Black

    [ValidateNotNullOrEmpty()][string]$MenuDeselected = "[ ]"
    [ValidateNotNullOrEmpty()][string]$MenuSelected = "[x]"
    [ValidateNotNullOrEmpty()][string]$MenuCannotSelect = "[/]"
    [ValidateNotNullOrEmpty()][string]$MenuCannotDeselect = "[!]"
    [ValidateNotNullOrEmpty()][ConsoleColor]$MenuInfoColor = [ConsoleColor]::DarkYellow
    [ValidateNotNullOrEmpty()][ConsoleColor]$MenuErrorColor = [ConsoleColor]::DarkRed

    hidden [object[]]$SelectedItems = $null
    hidden [int]$CurrentIndex = 0
    hidden [string]$Error = $null
    hidden [bool]$Help = $false
    hidden [bool]$Info = $false

    InteractiveMultiMenu([string]$header, [InteractiveMultiMenuItem[]]$items) {
        $this.Header = $header
        $this.Items = $items | Sort-Object { $_.Order }
    }

    [object[]] GetSelections() {
        Clear-Host
        $shouldContinue = $true
        do {
            [Console]::CursorLeft = 0
            [Console]::CursorTop = 0
            if ($this.Help) {
                Clear-Host
                $this.ShowHelp()
                [Console]::ReadKey("NoEcho,IncludeKeyDown")
                $this.Help = $false
                Clear-Host
                continue
            }
            if ($this.Info) {
                Clear-Host
                $this.ShowCurrentItemInfo()
                [Console]::ReadKey("NoEcho,IncludeKeyDown")
                $this.Info = $false
                Clear-Host
                continue
            }

            Write-Host "$($this.Header)`n" -ForegroundColor $this.HeaderColor
            $this.Draw()
            $this.ShowUsage()

            $this.ShowErrors()
    
            $keyPress = [Console]::ReadKey("NoEcho,IncludeKeyDown")
            $shouldContinue = $this.ProcessKey($keyPress)
        } while ($shouldContinue)

        return $this.SelectedItems
    }

    [void] SetOptions([hashtable]$options) {
        foreach ($option in $options.GetEnumerator()) {
            if ($null -eq $this.$($option.Key)) {
                Write-Host "Invalid option key: $($option.Key)"
            } else {
                $this.$($option.Key) = $option.Value
            }
        }
    }

    hidden Draw() {
        $defaultForegroundColor = (get-host).ui.rawui.ForegroundColor
        $defaultBackgroundColor = (get-host).ui.rawui.BackgroundColor
    
        $i = 0
        $this.Items | ForEach-Object {
            $currentItem = $_
            $color = $defaultForegroundColor
            $background = $defaultBackgroundColor
            $linkColor = $this.LinkColor
            $selectionStatus = $this.MenuDeselected
            if ($i -eq $this.CurrentIndex) {
                $background = $this.CurrentItemColor
                $linkColor = $this.CurrentItemLinkColor
            }
            if ($currentItem.Selected) {
                $selectionStatus = $this.MenuSelected
            }

            if ($currentItem.Readonly) {
                if ($currentItem.Selected) {
                    $selectionStatus = $this.MenuCannotDeselect
                } else {
                    $selectionStatus = $this.MenuCannotSelect
                }
            }
            
            Write-Host "$($selectionStatus) $($currentItem.Label)" -NoNewline -ForegroundColor $color -BackgroundColor $background
            if (-not [string]::IsNullOrEmpty($currentItem.Url)) {
                Write-Host " [$($currentItem.Url)]" -ForegroundColor $linkColor -BackgroundColor $background
            } else {
                Write-Host
            }
            $i++
        }
    }

    hidden ShowCurrentItemInfo() {
        $selectedItem = $this.GetSelectedItem();
        
        Write-Host "`n$($selectedItem.Info)" -ForegroundColor $this.MenuInfoColor
        Write-Host "`nPress any key to go back" -ForegroundColor $this.HeaderColor
    }

    hidden [InteractiveMultiMenuItem] GetSelectedItem() {
        return $this.Items[$this.CurrentIndex];
    }

    hidden [bool] ProcessKey($keyPress) {
        switch ($keyPress.Key) {
            $([ConsoleKey]::DownArrow) {
                $this.CurrentIndex++
                if ($this.CurrentIndex -ge $this.Items.Length) {
                    $this.CurrentIndex = $this.Items.Length -1;
                }
            }
            $([ConsoleKey]::D2) { # this is only for powersession
                $this.CurrentIndex++
                if ($this.CurrentIndex -ge $this.Items.Length) {
                    $this.CurrentIndex = $this.Items.Length -1;
                }
            }
            $([ConsoleKey]::UpArrow) {
                $this.CurrentIndex--
                if ($this.CurrentIndex -lt 0) {
                    $this.CurrentIndex = 0;
                }
            }
            $([ConsoleKey]::D8) { # this is only for powersession
                $this.CurrentIndex--
                if ($this.CurrentIndex -lt 0) {
                    $this.CurrentIndex = 0;
                }
            }
            $([ConsoleKey]::Spacebar) {
                $selectedItem = $this.GetSelectedItem()
                if ($selectedItem.Readonly) {
                    $this.Error = "$($selectedItem.Label) is marked as readonly and cannot be changed"
                } else {
                    $selectedItem.Selected=!$selectedItem.Selected;
                }
            }
            $([ConsoleKey]::A) {
                $this.Items | ForEach-Object {
                    if (-not $_.Readonly) {
                        $_.Selected = $true
                    }
                }
            }
            $([ConsoleKey]::N) {
                $this.Items | ForEach-Object {
                    if (-not $_.Readonly) {
                        $_.Selected = $false
                    }
                }
            }
            $([ConsoleKey]::H) {
                $this.Help = $true
            }
            $([ConsoleKey]::O) {
                $this.OpenBrowser()
            }
            $([ConsoleKey]::I) {
                $selectedItem = $this.GetSelectedItem()
                if (-not [string]::IsNullOrEmpty($selectedItem.Info)) {
                    $this.Info = $true
                }
            }
            $([ConsoleKey]::Enter) {
                $this.StoreState()
                return $false
            }
            $([ConsoleKey]::Escape) {
                return $false
            }
            Default {
                $this.Error = "Unkown key pressed: $_. Press 'h' for help."
            }
        }
        return $true
    }

    hidden OpenBrowser() {
        $selectedItem = $this.GetSelectedItem()
        if (-not [string]::IsNullOrEmpty($selectedItem.Url)) {
            Start-Process "$($selectedItem.Url)"
        } else {
            $this.Error = "$($selectedItem.Label) doesn't have an URL"
        }
    }

    hidden StoreState() {
        $this.SelectedItems = @()
        foreach ($item in $this.Items) {
            if ($item.Selected) {
                $this.SelectedItems += $item.ItemInfo
            }
        }
    }

    hidden ShowHelp() {
        Write-Host "Legend:"
        Write-Host -NoNewline $this.MenuDeselected -ForegroundColor $this.HelpColor
        Write-Host " - unchecked item"
        Write-Host -NoNewline $this.MenuSelected -ForegroundColor $this.HelpColor
        Write-Host " - checked item"
        Write-Host -NoNewline $this.MenuCannotDeselect -ForegroundColor $this.HelpColor
        Write-Host " - mandatory (cannot uncheck)"
        Write-Host -NoNewline $this.MenuCannotSelect -ForegroundColor $this.HelpColor
        Write-Host " - unavailable (cannot check)"
        
        Write-Host "Usage:"
        Write-Host -NoNewline "[SpaceBar]" -ForegroundColor $this.HelpColor
        Write-Host -NoNewline " check/uncheck, "
        Write-Host -NoNewline "[Enter]" -ForegroundColor $this.HelpColor
        Write-Host -NoNewline " continue, "
        Write-Host -NoNewline "[Esc]" -ForegroundColor $this.HelpColor
        Write-Host " exit"
        Write-Host -NoNewline "[Up] [Down]" -ForegroundColor $this.HelpColor
        Write-Host -NoNewline " navigate, "
        Write-Host -NoNewline "[A]" -ForegroundColor $this.HelpColor
        Write-Host -NoNewline " select all, "
        Write-Host -NoNewline "[N]" -ForegroundColor $this.HelpColor
        Write-Host " deselect all"
        Write-Host -NoNewline "[O]" -ForegroundColor $this.HelpColor
        Write-Host " open url (if any)"
        Write-Host -NoNewline "[I]" -ForegroundColor $this.HelpColor
        Write-Host " show information about selected item (if any)"

        Write-Host "`nPress any key to go back" -ForegroundColor $this.HeaderColor
    }

    hidden ShowUsage() {
        Write-Host "`nPress [h] for help." -ForegroundColor $this.HelpColor
    }

    hidden ShowErrors() {
        $bufferFill = "                                                                                                                                              "
        if (-not [string]::IsNullOrEmpty($this.Error)) {
            Write-Host "$($this.Error)$bufferFill" -ForegroundColor $this.MenuErrorColor
            $this.Error = $null
        } else {
            Write-Host $bufferFill
        }
    }
}

class InteractiveMenuChooseMenuItem {
    [ValidateNotNullOrEmpty()][string]$Label
    [ValidateNotNullOrEmpty()][string]$Value
    [ValidateNotNullOrEmpty()][string]$Info

    InteractiveMenuChooseMenuItem([string]$label, [string]$value, [string]$info) {
        $this.Label = $label
        $this.Value = $value
        $this.Info = $Info
    }
}

class InteractiveMenuChooseMenu {
    [ValidateNotNullOrEmpty()][string]$Question
    [ValidateNotNullOrEmpty()][InteractiveMenuChooseMenuItem[]]$Options

    [ValidateNotNullOrEmpty()][ConsoleColor]$MenuInfoColor = [ConsoleColor]::DarkYellow
    [ValidateNotNullOrEmpty()][ConsoleColor]$QuestionColor = [ConsoleColor]::Magenta
    [ValidateNotNullOrEmpty()][ConsoleColor]$HelpColor = [ConsoleColor]::Cyan
    [ValidateNotNullOrEmpty()][ConsoleColor]$ErrorColor = [ConsoleColor]::DarkRed
    [ValidateNotNullOrEmpty()][ConsoleColor]$HighlightColor = [ConsoleColor]::DarkGreen
    [ValidateNotNullOrEmpty()][string]$OptionSeparator = "      "

    hidden [int]$CurrentIndex = 0
    hidden [InteractiveMenuChooseMenuItem]$SelectedOption = $null
    hidden [bool]$Help = $false
    hidden [string]$Error = $null

    InteractiveMenuChooseMenu([string]$question, [InteractiveMenuChooseMenuItem[]]$options) {
        $this.Question = $question
        $this.Options = $options
    }

    [string] GetAnswer() {
        $shouldContinue = $true
        do {
            Clear-Host
            if ($this.Help) {
                $this.ShowHelp()
                [Console]::ReadKey("NoEcho,IncludeKeyDown")
                continue
            }

            Write-Host "$($this.Question)`n" -ForegroundColor $this.QuestionColor
            $this.Draw()
            $this.ShowCurrentItemInfo()
            $this.ShowUsage()
            $this.ShowErrors()
    
            $keyPress = [Console]::ReadKey("NoEcho,IncludeKeyDown")
            $shouldContinue = $this.ProcessKey($keyPress)
        } while ($shouldContinue)

        if ($null -eq $this.SelectedOption) {
            return $null
        }
        return $this.SelectedOption.Value
    }

    [void] SetOptions([hashtable]$options) {
        foreach ($option in $options.GetEnumerator()) {
            if ($null -eq $this.$($option.Key)) {
                Write-Host "Invalid option key: $($option.Key)"
            } else {
                $this.$($option.Key) = $option.Value
            }
        }
    }

    hidden Draw() {
        $defaultForegroundColor = (get-host).ui.rawui.ForegroundColor
        $defaultBackgroundColor = (get-host).ui.rawui.BackgroundColor

        $i = 0
        $this.options | ForEach-Object {
            $foregroundColor = $defaultForegroundColor
            $backgroundColor = $defaultBackgroundColor
            if ($i -eq $this.CurrentIndex) {
                $backgroundColor = $this.HighlightColor
            }
            Write-Host " $($_.Label) " -NoNewline -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
            Write-Host $this.OptionSeparator -NoNewline
            $i++
        }
        Write-Host
    }

    hidden ShowCurrentItemInfo() {
        $selectedItem = $this.Options[$this.CurrentIndex];
        if (-not [string]::IsNullOrEmpty($selectedItem.Info)) {
            Write-Host "`n$($selectedItem.Info)" -ForegroundColor $this.MenuInfoColor
        }
    }

    hidden [bool] ProcessKey($keyPress) {
        switch ($keyPress.Key) {
            $([ConsoleKey]::RightArrow) {
                $this.CurrentIndex++
                if ($this.CurrentIndex -ge $this.Options.Length) {
                    $this.CurrentIndex = $this.Options.Length -1;
                }
            }
            $([ConsoleKey]::D6) { # this is only for powersession
                $this.CurrentIndex++
                if ($this.CurrentIndex -ge $this.Options.Length) {
                    $this.CurrentIndex = $this.Options.Length -1;
                }
            }
            $([ConsoleKey]::LeftArrow) {
                $this.CurrentIndex--
                if ($this.CurrentIndex -lt 0) {
                    $this.CurrentIndex = 0;
                }
            }
            $([ConsoleKey]::D4) { # this is only for powersession
                $this.CurrentIndex--
                if ($this.CurrentIndex -lt 0) {
                    $this.CurrentIndex = 0;
                }
            }
            $([ConsoleKey]::H) {
                $this.Help = $true
            }
            $([ConsoleKey]::Enter) {
                $this.StoreState()
                return $false
            }
            $([ConsoleKey]::Escape) {
                return $false
            }
            Default {
                $this.Error = "Unkown key pressed: $_. Press 'h' for help."
            }
        }
        return $true
    }

    hidden StoreState() {
        $this.SelectedOption = $this.Options[$this.CurrentIndex]
    }

    hidden ShowUsage() {
        Write-Host "`nPress [h] for help." -ForegroundColor $this.HelpColor
    }

    hidden ShowErrors() {
        $bufferFill = "                                                                                                                                              "
        if (-not [string]::IsNullOrEmpty($this.Error)) {
            Write-Host "$($this.Error)$bufferFill" -ForegroundColor $this.ErrorColor
            $this.Error = $null
        } else {
            Write-Host $bufferFill
        }
    }

    hidden ShowHelp() {
        Write-Host "Usage:"
        Write-Host -NoNewline "[Enter]" -ForegroundColor $this.HelpColor
        Write-Host -NoNewline " continue, "
        Write-Host -NoNewline "[Esc]" -ForegroundColor $this.HelpColor
        Write-Host " exit"
        Write-Host -NoNewline "[Lef] [Right]" -ForegroundColor $this.HelpColor
        Write-Host " navigate, "

        Write-Host "`nPress any key to go back" -ForegroundColor $this.QuestionColor
        $this.Help = $false
    }
}

function Get-InteractiveMultiMenuOption {
    param(
        [Parameter(Mandatory)][object]$Item,
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][int]$Order,
        [Parameter()][switch]$Selected,
        [Parameter()][switch]$Readonly,
        [Parameter()][string]$Info,
        [Parameter()][string]$Url
    )
    [InteractiveMultiMenuItem]::New($Item, $Label, $Selected.IsPresent, $Order, $Readonly.IsPresent, $Info, $Url)
} 

function Get-InteractiveMenuUserSelection {
    param(
        [Parameter(Mandatory)][string]$Header,
        [Parameter(Mandatory)][object[]]$Items,
        [Parameter()][hashtable]$Options
    )
    $menu = [InteractiveMultiMenu]::New($Header, $Items)
    if ($null -ne $Options) {
        $menu.SetOptions($Options);
    }
    return $menu.GetSelections()
}

function Get-InteractiveChooseMenuOption() {
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][string]$Value,
        [Parameter(Mandatory)][string]$Info
    )

    [InteractiveMenuChooseMenuItem]::new($Label, $Value, $Info)
}

function Get-InteractiveMenuChooseUserSelection {
    param(
        [Parameter(Mandatory)][string]$Question,
        [Parameter(Mandatory)][object[]]$Answers,
        [Parameter()][hashtable]$Options
    )

    $menu = [InteractiveMenuChooseMenu]::new($Question, $Answers)
    if ($null -ne $Options) {
        $menu.SetOptions($Options);
    }
    return $menu.GetAnswer()
}

Export-ModuleMember -Function Get-InteractiveMultiMenuOption,Get-InteractiveMenuUserSelection,Get-InteractiveChooseMenuOption,Get-InteractiveMenuChooseUserSelection