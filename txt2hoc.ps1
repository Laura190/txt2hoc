# Get command line parameters
param(
	[Parameter(Mandatory)]
	[String]$in,
	[String]$out
)

#Read input file contents
$content = Get-Content -Path $in | ForEach-Object {$_.Trim() -replace "\s+", " "}
$num_sections = ((Select-String -Path $in -Pattern '#' -AllMatches).Matches.Value | Group-Object -NoElement).Count

#Begin output file
"objref Undefined`r`nUndefined = new SectionList()" | Set-Content -Path $out
"create sections[$num_sections]`r`n" | Add-Content -Path $out

#Reformat .txt to .hoc
$count = 0
foreach($line in $content) {
	if($line -like '[0-9]*') {
		$x = $line | ForEach-Object {$_.split(" ")[2]}
		$y = $line | ForEach-Object {$_.split(" ")[3]}
		$z = $line | ForEach-Object {$_.split(" ")[4]}
		"	pt3dadd($x, $y, $z, 1)" | Add-Content -Path $out
	}
	elseif($line -like '#*') {
		if($count -gt 0) {
		"}`r`n" | Add-Content -Path $out
		}
		"access sections[$count]`r`nUndefined.append()`r`nsections[$count] {" | Add-Content -Path $out
		$count=$count+1
	}
}
"}" | Add-Content -Path $out