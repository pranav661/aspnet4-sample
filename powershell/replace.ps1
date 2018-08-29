Param(
  [string]$configLoc,
  [string]$config_with_valuesLoc
)

$tokens = (Get-Content $configLoc | select-string -pattern "{.*?}").length

$lines = Get-Content $configLoc | select-string -pattern "{.*?}" | Out-String
$lines = $lines.replace(' ','').Trim()


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
$property,$garbage = $holder.split("{")
getvalue -prop $property -holder $holder
#echo "$property"
}


For ($i=0; $i -lt $tokens; $i++)
{
$line = ($lines -split '\r?\n')[$i]
getproperty -holder $line
}



#Things still needed to be done:-  (Ask Prakash Sir)
#1) Error Handling (If number of tokens and values to be replaced do not match)
#2) Will this script run for complex .config files ??
#3) Re-explain the scenario (Where config will sit and all, Should a new file be created & used for deployment or directly change the file in WEBAPP AZURE)