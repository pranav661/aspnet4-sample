#powershell version must be 5.1
#This script will work only for projects have only 1 web.config file
#If we want it to work for more web.config files, changes in the logic need to be done.

param (
 [string]$loc,
 [string]$envt
)

cd "$loc"
dir                                              
                                             
mkdir temp
cd temp  

$temploc = pwd
                               
$ziploc = Get-ChildItem $loc -Filter *.zip -Recurse | % { $_.FullName } | Out-String
$ziploc = $ziploc.Trim()

#extracting the default zip file
expand-archive -path $ziploc -destinationpath $temploc

$configLoc = Get-ChildItem $temploc -Filter Web.config -Recurse | % { $_.FullName } | Out-String
$configLoc = ($configLoc -split '\r?\n')[0]
$configLoc = $configLoc.Trim()

$content = Get-Content $configLoc
echo "$content"

function getlocation {
Param($uri)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-WebRequest -Uri "$uri" -UseBasicParsing
$objects = $Response.Content
echo "$objects"
Out-File -FilePath "$loc\conf-with-val.config" -InputObject $objects
cd "$loc"
dir
$config_with_valuesLoc = "$loc\conf-with-val.config"
echo "$config_with_valuesLoc"
$a = Get-Content conf-with-val.config
echo "$a"
}

## getting config with values location according to environment
if($envt -contains "Dev")
{
$uri = "https://raw.githubusercontent.com/pranav661/aspnet4-sample/master/config-with-values/dev_web.config"
getlocation -uri $uri
}
if($envt -contains "QA")
{
$uri = "https://raw.githubusercontent.com/pranav661/aspnet4-sample/master/config-with-values/qa_web.config"
getlocation -uri $uri
}

$tokens = (Get-Content $configLoc | select-string -pattern "{.*?}").length

$lines = Get-Content $configLoc | select-string -pattern "{.*?}" | Out-String
$lines = $lines.Trim()


function replacing {
Param($holder,$value)
$original = Get-Content $configLoc
$original | % { $_.Replace("$holder", "$value") } | Set-Content $configLoc
}

function getvalue {
Param($prop,$holder)
$value = Get-Content $config_with_valuesLoc | findstr $prop | Out-String | ForEach-Object { $_.Trim() }
replacing -holder $holder -value $value
}

function getproperty {
Param($holder)
$property = $holder.split(" ")[1]
$property = $property.split("=")[1]
$property = $property.Trim()
getvalue -prop $property -holder $holder
}

For ($i=0; $i -lt $tokens; $i++)
{
$line = ($lines -split '\r?\n')[$i]
#echo "$line"
getproperty -holder $line
}

#removing old zip file
rm $ziploc

#removing config file with values
rm $config_with_valuesLoc
