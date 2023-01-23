class BlockKit_HeaderBlock {
    hidden [string]$type = "header"
    $text = [System.Collections.Generic.Dictionary[string, object]]::new()

    BlockKit_HeaderBlock([string]$Text) {
        $this.text.Add("type", "plain_text")
        $this.text.Add("text", $Text)
    }
}

class BlockKit_TextType {
    $Value = ""
    static [BlockKit_TextType]$PlainText = ([BlockKit_TextType]::new("plain_text"))
    static [BlockKit_TextType]$Markdown = ([BlockKit_TextType]::new("mrkdwn"))

    hidden BlockKit_TextType($val) {
        $this.Value = $val
    }

    [String] ToString() {
        return $this.Value
    }
}


class BlockKit_PlainTextSectionField {
    hidden [string]$text
    hidden [string]$type
    hidden [bool]$emoji
    BlockKit_PlainTextSectionField([string]$Text) {
        $this.type = [BlockKit_TextType]::PlainText.ToString()
        switch ($Text) {
            { "" -eq $_ -or $null -eq $_ } { $this.text = "---" }
            Default { $this.text = $Text }
        }
    }
    BlockKit_PlainTextSectionField([string]$Text, [Bool]$Emoji) {
        $this.type = [BlockKit_TextType]::PlainText.ToString()
        $this.emoji = $Emoji
        switch ($Text) {
            { "" -eq $_ -or $null -eq $_ } { $this.text = "---" }
            Default { $this.text = $Text }
        }        
    }
}

class BlockKit_MarkdownSectionField {
    hidden [string]$text
    hidden [string]$type
    BlockKit_MarkdownSectionField([string]$Text) {
        $this.type = [BlockKit_TextType]::Markdown.ToString()
        switch ($Text) {
            { "" -eq $_ -or $null -eq $_ } { $this.text = "---" }
            Default { $this.text = $Text }
        }
    }
}

class BlockKit_PlainTextSectionBlock {
    hidden [string]$type = "section"
    $text = [PSCustomObject]@{
        type  = [BlockKit_TextType]::PlainText.ToString()
        text  = ""
        emoji = $false
    }

    BlockKit_PlainTextSectionBlock([string]$Body) {
        $this.text.text = $Body
    }

    BlockKit_PlainTextSectionBlock([string]$Body, [bool]$Emoji) {
        $this.text.text = $Body
        $this.text.emoji = $Emoji
    }
}

class BlockKit_MarkdownSectionBlock {
    hidden [string]$type = "section"
    $text = [PSCustomObject]@{
        type = [BlockKit_TextType]::Markdown.ToString()
        text = ""
    }

    BlockKit_MarkdownSectionBlock([string]$Body) {
        $this.text.text = $Body
    }
}


class BlockKit_TextFieldSectionBlock {
    hidden [string]$type = "section"
    $fields = [System.Collections.Generic.List[object]]::new()

    [void]AddField($obj) {
        $this.fields.Add($obj)
    }
}

class BlockKit_Builder {
    hidden $blocks = [System.Collections.Generic.List[object]]::new()

    [string]$Text = ""

    [void]Add($Block) {
        $this.blocks.Add($Block)
    }

    [string]JSON() {
        $outputObj = $null
        switch ($this.Text) {
            "" {
                $outputObj = [PSCustomObject]@{
                    blocks = $this.blocks
                }
            }
            Default {
                $outputObj = [PSCustomObject]@{
                    text   = $this.Text
                    blocks = $this.blocks
                }
            }
        }

        return $outputObj | ConvertTo-Json -Depth 20
    }

}

<# EXPORTED POWERSHELL FUNCTIONS #>

function New-BlockKitTextOnlyLayout {
    param (
        $Body
    )
    return [pscustomobject]@{
        text = $Body
    } | ConvertTo-JSON
}

function New-BlockKitStandardLayout {
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Plaintext')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Markdown')]
        [string]$Title,
        [Parameter(Mandatory = $true, ParameterSetName = 'Plaintext')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Markdown')]
        [string]$Body,
        [Parameter(Mandatory = $false, ParameterSetName = 'Plaintext')]
        [switch]$SupportEmoji,
        [Parameter(Mandatory = $false, ParameterSetName = 'Markdown')]
        [switch]$Markdown
    )
    $titleBlock = [BlockKit_HeaderBlock]::new($Title)

    switch ($PSCmdlet.ParameterSetName) {
        "Plaintext" {
            $bodyBlock = [BlockKit_PlainTextSectionBlock]::new($Body, $SupportEmoji)
        }
        "Markdown" {
            $bodyBlock = [BlockKit_MarkdownSectionBlock]::new($Body)
        }
    }

    $BlockKitBuilder = [BlockKit_Builder]::new()
    $BlockKitBuilder.Add($titleBlock)
    $BlockKitBuilder.Add($bodyBlock)
    return $BlockKitBuilder.JSON()
}

function New-BlockKit2ColLayout {
    param (
        [string]$Title,
        [string]$Col1Header,
        [string]$Col2Header,
        [string[]]$Col1Data,
        [string[]]$Col2Data
    )
    $titleBlock = [BlockKit_HeaderBlock]::new($Title)
    $bodyBlock = [BlockKit_TextFieldSectionBlock]::new()
    
    # Add Column Headers
    $bodyBlock.AddField([BlockKit_MarkdownSectionField]::new(("*$Col1Header*")))
    $bodyBlock.AddField([BlockKit_MarkdownSectionField]::new(("*$Col2Header*")))

    # Add Column Data
    $totalCols = ($Col1Data.Count -ge $Col2Data.Count) ? $Col1Data.Count : $Col2Data.Count #Set totalCols to the biggest array passed to the function to avoid data truncation
    for ($i = 0; $i -lt $totalCols; $i++) {
        $bodyBlock.AddField([BlockKit_PlainTextSectionField]::new($Col1Data[$i])) #Col1 is always on the left so it is first
        $bodyBlock.AddField([BlockKit_PlainTextSectionField]::new($Col2Data[$i])) #Col2 has to be on the right so it is second in each iteration
    }

    $BlockKitBuilder = [BlockKit_Builder]::new()
    $BlockKitBuilder.Add($titleBlock)
    $BlockKitBuilder.Add($bodyBlock)
    return $BlockKitBuilder.JSON()
}