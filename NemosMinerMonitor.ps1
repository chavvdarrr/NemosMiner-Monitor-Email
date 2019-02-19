$path = $PSScriptRoot # get script folder
Set-Location $path #and set it as current

# set variables for sending mail
$sbj = "Nemos is not running" #subject
$rcv = "yourmail@server.com" # receiver of mail
$smtp = "smtp.server" # some smtp server
$from = "sender@your.server" #mail sender 

# Load HTML Agility Pack, assume it's alongside with the script
# can install Agility pack via nuget: https://www.nuget.org/packages/HtmlAgilityPack/
Add-Type -Path "C:\HtmlAgilityPack.1.9.0\lib\NetCore45\HtmlAgilityPack.dll” # path to agility lib

# Create new HTML Agility Pack document
$Hap = New-Object -TypeName HtmlAgilityPack.HtmlDocument

# Create new Internet Explorer COM object
$IE = New-Object -ComObject InternetExplorer.Application

# Navigate to page
$IE.Navigate("https://nemosminer.com/workers.php?user=your-user-id")

# Wait until navigation complete
while ($IE.Busy)
{
    Start-Sleep -Seconds 1
}

# Show Internet Explorer
# $IE.Visible = $true

# Get page source
$Hap.LoadHtml($IE.Document.body.parentElement.outerHTML)

# Do some HTML processing

    $table=$Hap.DocumentNode.Descendants("table")
    $cell = $table.descendants("td")|where {$_.xpath -eq "/html[1]/body[1]/div[1]/div[1]/div[1]/div[1]/div[2]/div[2]/table[1]/tbody[1]/tr[1]/td[3]"}
    $res = $cell.InnerText
   #debug
   #write-host " Miner is: $res " -ForegroundColor Green
    if ($res -ne "Running") {
        #send mail if not running
        $cell = $table.descendants("td")|where {$_.xpath -eq "/html[1]/body[1]/div[1]/div[1]/div[1]/div[1]/div[2]/div[2]/table[1]/tbody[1]/tr[1]/td[4]"}
        $time = $cell.InnerText
        $Body = "Status: $res . It is not running since $time " 
        # Uncomment if wanna send email. Set correct variables
        # Send-MailMessage -to $rcv -from $from -subject $sbj -body $Body -SmtpServer $smtp
        # can add attachment too: -Attachments "useful.txt"
    }

# Close Internet Explorer
$IE.Quit()

# Cleanup
Remove-Variable IE -Force
