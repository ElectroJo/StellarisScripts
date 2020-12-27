#Adds the ability for powershell to work with ZIP files
Add-Type -Assembly System.IO.Compression.FileSystem

#Gets all .zip files in current directory
$ModList = Get-ChildItem "$pwd" -Filter *.zip

#Iterate through each zip file
$ModList | Foreach-Object {

	#Creates a string composing of the current directory + a backslash + the name of the zip file
	$ZipNamePath = "$pwd"+"\"+$_.Name
	
	#Decompresses the zip in memory
	$zip = [IO.Compression.ZipFile]::OpenRead($ZipNamePath)
	
	#Creates a string that is the name of the zip file without the zip extension
	$ZipName = $_.Name.TrimEnd(".zip")
	
	#Creates a string of what the .mod file should be nammed. It is the current directroy + a back slash + the name of the zip without the .zip extension + the .mod extension
	$ModNamePath = "$pwd"+"\"+"$ZipName"+".mod"
	
	#Extracts the description.mod file and renames it to the name of the zip file
	$zip.Entries | where {$_.Name -like 'descriptor.mod'} | foreach {[System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$ModNamePath", $true)}
	
	#Closes the zip file open in memory
	$zip.Dispose()
	
	#If the description file allready has a path variable set
	if ((Get-Content $ModNamePath) -Match "path") {
		
		#Get the line with the "path" string
		$line = Get-Content $ModNamePath | Select-String "path" | Select-Object -ExpandProperty Line
		
		#Get all text in the .mod file
		$content = Get-Content $ModNamePath
		
		#Creates a string with the correct archivepath line
		$replacetext = "archive="+'"'+"$pwd"+"/$ZipName"+".zip"+'"'
		
		#Replaces the line with the path in the .mod file with the archivepath
		$content | ForEach-Object {$_ -replace $line,$replacetext} | Set-Content $ModNamePath
		
	#If the document instead contains an archivepath, do the same thing as above but with archive path
	} elseif ((Get-Content $ModNamePath) -Match "archive") {
		$line = Get-Content $ModNamePath | Select-String "archive" | Select-Object -ExpandProperty Line
		$content = Get-Content $ModNamePath
		$replacetext = "archive="+'"'+"$pwd"+"/$ZipName"+".zip"+'"'
		$content | ForEach-Object {$_ -replace $line,$replacetext} | Set-Content $ModNamePath
		
	#If the document doesn't contain either, just add an archivepath to the end of the file
	} else {
		$content = Get-Content $ModNamePath
		$addtext = "`r`narchive="+'"'+"$pwd"+"/$ZipName"+".zip"+'"'
		Add-Content $ModNamePath $addtext
	}
	#replaces all backslashes with a forward slash as needed for stellaris to find the mod
	(Get-Content $ModNamePath).replace('\', '/') | Set-Content $ModNamePath
}


