Add-Type -Assembly System.IO.Compression.FileSystem
$ModList = Get-ChildItem "$pwd" -Filter *.zip
$ModList | Foreach-Object {
	$ZipNamePath = "$pwd"+"\"+$_.Name
	$zip = [IO.Compression.ZipFile]::OpenRead($ZipNamePath)
	$ZipName = $_.Name.TrimEnd(".zip")
	$ModNamePath = "$pwd"+"\"+"$ZipName"+".mod"
	$zip.Entries | where {$_.Name -like 'descriptor.mod'} | foreach {[System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$ModNamePath", $true)}
	$zip.Dispose()
	if ((Get-Content $ModNamePath) -Match "path") {
		$line = Get-Content $ModNamePath | Select-String "path" | Select-Object -ExpandProperty Line
		$content = Get-Content $ModNamePath
		$replacetext = "archive="+'"'+"$pwd"+"/$ZipName"+".zip"+'"'
		$content | ForEach-Object {$_ -replace $line,$replacetext} | Set-Content $ModNamePath
	} elseif ((Get-Content $ModNamePath) -Match "archive") {
		$line = Get-Content $ModNamePath | Select-String "archive" | Select-Object -ExpandProperty Line
		$content = Get-Content $ModNamePath
		$replacetext = "archive="+'"'+"$pwd"+"/$ZipName"+".zip"+'"'
		$content | ForEach-Object {$_ -replace $line,$replacetext} | Set-Content $ModNamePath
	} else {
		$content = Get-Content $ModNamePath
		$addtext = "`r`narchive="+'"'+"$pwd"+"/$ZipName"+".zip"+'"'
		Add-Content $ModNamePath $addtext
	}
	(Get-Content $ModNamePath).replace('\', '/') | Set-Content $ModNamePath
}


