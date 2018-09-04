#powershell version must be 5.1
#This script will work only for projects have only 1 web.config file
#If we want it to work for more web.config files, changes in the logic need to be done.

#Or this task can be done by using replace tokens plugins from marketplace which is third party sw.

param (
 [string]$loc
)

cd "$loc"
dir                                              
                                             
mkdir temp

cd temp  

$temploc = pwd
                               
$ziploc = Get-ChildItem $loc -Filter *.zip -Recurse | % { $_.FullName } | Out-String
$ziploc = $ziploc.Trim()

expand-archive -path $ziploc -destinationpath $temploc

$configLoc = Get-ChildItem $temploc -Filter Web.config -Recurse | % { $_.FullName } | Out-String
$configLoc = ($configLoc -split '\r?\n')[0]
$configLoc = $configLoc.Trim()

$content = Get-Content $configLoc
echo "$content"

## getting config with values location
## right now only hard coded and that also for dev envt
## serious work has to be done


$config_with_valuesLoc = Get-ChildItem $loc -Filter dev_web.config -Recurse | % { $_.FullName } | Out-String
$config_with_valuesLoc = $config_with_valuesLoc.Trim()
echo "$config_with_valuesLoc"

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
