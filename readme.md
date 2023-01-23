# PowerShell Slack BlockKit Module
## Summary
This module provides simple functions to build formatted Slack messages to send to a Slack webhook

## Getting started
Build a Slack App using the guide here: https://api.slack.com/messaging/webhooks

Retrieve the webhook URI. It should look like this:
`https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX`

In your PowerShell script, you will POST JSON data to this URI like so:
```powershell
$webhookURI = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"

Invoke-RestMethod $webhookURI -Method POST -Body $webhookData -ContentType "application/json"

```

## Functions
---

### **New-BlockKitTextOnlyLayout**
Allows you to send a simple message as you would type in a chat window
#### Usage
```powershell
$webhookData = New-BlockKitTextOnlyLayout -Body "This is a text only layout test"

Invoke-RestMethod $webhookURI -Method POST -Body $webhookData -ContentType "application/json"
```
---

### **New-BlockKitStandardLayout**
Allows you to send a message with a header and either plain-text or markdown content
#### Usage
```powershell
#Send plain text with optional emoji support
$webhookData = New-BlockKitStandardLayout -Title "Hello World" -Body "Testing plain text :coffee_parrot:" -SupportEmoji

Invoke-RestMethod $webhookURI -Method POST -Body $webhookData -ContentType "application/json"


#Send plain text with optional emoji support
$webhookData = New-BlockKitStandardLayout `
  -Title "Hello World" `
  -Body "Testing if _markdown_ *format* ``works``" `
  -Markdown #Markdown Switch changes Param Set to use Markdown Type

Invoke-RestMethod $webhookURI -Method POST -Body $webhookData -ContentType "application/json"
```
---

### **New-BlockKit2ColLayout**
Allows you to send a two-column "table" to a slack channel

Your data needs to be in two `[string[]]` arrays. If one array is smaller than the other, it will fill in data for that column until it encounters null/blank values and it will replace them with three dashes `---`

#### Usage
```powershell
[string[]]$col1 = @("this 1", "is 1", "col 1")
[string[]]$col2 = @("this is an uneven array")

$webhookData = New-BlockKit2ColLayout -Title "2 Column Layout Test" -Col1Header "Header 1" -Col2Header "Header 2" -Col1Data $col1 -Col2Data $col2

Invoke-RestMethod $webhookURI -Method POST -Body $webhookData -ContentType "application/json"
```
#### Output in slack (approximation)

```
2 Column Layout Test

Header 1            Header 2
this 1              this is an uneven array
is 1                ---
col 1               ---
```
---