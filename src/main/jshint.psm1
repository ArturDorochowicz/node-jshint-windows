Remove-Module JSHint -ErrorAction SilentlyContinue

function Invoke-JSHint {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0)] [string[]] $PathList,
		[Parameter(Position=1)] [string] $ConfigFile,
		[Parameter(Position=2)] [string] $ReportFile,
		[string] [ValidateSet('Default', 'DefaultNonError', 'JSLint', 'VSReporter')] $ReporterType = 'VSReporter',
		[string] $Reporter
	)
	
	$JSHint = "${PSScriptRoot}/jshint.bat"
	$Reporters = @{
		'Default' = "${PSScriptRoot}/lib/node_modules/jshint/lib/reporters/default.js"
		'DefaultNonError' = "${PSScriptRoot}/lib/node_modules/jshint/lib/reporters/non_error.js"
		'JSLint' = "${PSScriptRoot}/lib/node_modules/jshint/lib/reporters/jslint_xml.js"
		'VSReporter' = "${PSScriptRoot}/lib/vs_reporter.js"
	}
	
	$arguments = @()
	$arguments += $PathList
	
	if ($ConfigFile) {
		$arguments += @('--config', $ConfigFile)
	}

	if ($Reporter) {
		$ReporterFile = $Reporter
	} else {
		$ReporterFile = $Reporters[$ReporterType] 
	}

	$arguments += @('--reporter', $ReporterFile)

	Write-Verbose "Running JSHint: `n${JSHint} ${arguments}"
	
	if ($ReportFile) {
		(& ${JSHint} $arguments) | Tee-Object -Variable ReportFileContent
	} else {
		(& ${JSHint} $arguments)
	}
	$jshintExitCode = $LASTEXITCODE	
	
	if (${ReportFile}) {
		Out-File -InputObject ${ReportFileContent} -FilePath ${ReportFile} -Encoding UTF8
	}
	
	if ($jshintExitCode -ne 0) {
		Write-Error -Message "JSHint returned nonzero exit code: ${jshintExitCode}."
	}
}

Export-ModuleMember Invoke-JSHint
