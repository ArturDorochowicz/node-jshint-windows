Remove-Module JSHint -ErrorAction SilentlyContinue

function Invoke-JSHint {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0)] [string[]] $PathList,
		[Parameter(Position=1)] [string] $ConfigFile,
		[Parameter(Position=2)] [string] $ReportFile,
		[string] $Reporter,
		[switch] $JSLintReporter,
		[switch] $ShowNonErrors
	)
	$JSHint = "${PSScriptRoot}/jshint.bat"
	$VSReporter = "${PSScriptRoot}/lib/vs_reporter.js"
	# Use VS reporter by default.
	$useVSReporter = (!$Reporter -and !$JSLintReporter -and !$ShowNonErrors)
	
	$arguments = @()
	$arguments += $PathList
	
	if ($ConfigFile) {
		$arguments += @('--config', $ConfigFile)
	}

	if ($useVSReporter) {
		$arguments += @('--reporter', $VSReporter);
	}
	
	if ($Reporter) {
		$arguments += @('--reporter', $Reporter)
	}
	
	if ($JSLintReporter) {
		$arguments += '--jslint-reporter'
	}
	
	if ($ShowNonErrors) {
		$arguments += '--show-non-errors'
	}
	
	Write-Verbose "Running JSHint: `n${JSHint} ${arguments}"
	
	if ($ReportFile -or $useVSReporter) {
		(& ${JSHint} $arguments) | Tee-Object -Variable ReportFileContent
	} else {
		(& ${JSHint} $arguments)
	}
	$jshintExitCode = $LASTEXITCODE	
	if ($useVSReporter -and $ReportFileContent) {
		Write-Verbose "VS Reporter was used. Failure detected by checking the existance of output."
		$jshintExitCode = 1
	}	
	
	if (${ReportFile}) {
		Out-File -InputObject ${ReportFileContent} -FilePath ${ReportFile} -Encoding UTF8
	}
	
	if ($jshintExitCode -ne 0) {
		Write-Error -Message "JSHint returned nonzero exit code: ${jshintExitCode}."
	}
}

Export-ModuleMember Invoke-JSHint
