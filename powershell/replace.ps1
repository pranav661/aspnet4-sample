echo "Starting to replace the tokens in Web.config file"

$configLoc = "$(Build.SourcesDirectory)\aspnet4-sample\Web.config"
$config_with_valuesLoc = "$(Build.SourcesDirectory)\powershell\config_with_values.config"

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
echo "$value"
replacing -holder $holder -value $value
}


function getproperty {
Param($holder)
$property = $holder.split(" ")[1]
$property = $property.split("=")[1]
$property = $property.Trim()
echo "$property"

getvalue -prop $property -holder $holder
}


For ($i=0; $i -lt $tokens; $i++)
{
$line = ($lines -split '\r?\n')[$i]
#echo "$line"
getproperty -holder $line
}



