# Get command line parameters
param(
	[Parameter(Mandatory)]
	[String]$in,
	[String]$out
)

#Read input file contents
$content = Get-Content -Path $in | ForEach-Object {$_.Trim() -replace "\s+", ","}
$num_sections = ((Select-String -Path $in -Pattern '#' -AllMatches).Matches.Value | Group-Object -NoElement).Count

#Begin output file
"objref Undefined`r`nUndefined = new SectionList()" | Set-Content -Path $out
"create sections[$num_sections]" | Add-Content -Path $out

#Reformat file
$delete_definitions = $content.Where({ $_ -like ("#*") },"SkipUntil")
$reformat_measurements = $delete_definitions | %{$arr=$_.Split(','); "pt3dadd({0},{1},{2},1)" -f $arr[2], $arr[3], $arr[4]}
$script:i=0
$add_sections=[regex]::replace($reformat_measurements, "pt3dadd\(,,,1\)", {"`r`n}`r`naccess sections[$($script:i)]`r`nUndefined.append()`r`nsections[$script:i]{`r`n"; $script:i++})
[regex]$pattern="}"
$remove_first_bracket=$pattern.replace($add_sections, " ", 1)
$add_newlines=[regex]::replace($remove_first_bracket, "\) pt3dadd\(", ")`r`n pt3dadd(")
$add_newlines | Add-Content -Path $out
"}" | Add-Content -Path $out