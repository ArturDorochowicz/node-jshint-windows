Remove-Module JSHint -ErrorAction SilentlyContinue

function Invoke-JSHint {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0)] [string[]] ${PathList},
		[Parameter(Position=1)] [string] ${CustomConfigFile},
		[Parameter(Position=2)] [string] ${ReportFile},
		[string] ${CustomReporter},
		[switch] ${JSLintReporter}
	)
	${JSHint} = "${PSScriptRoot}/jshint.bat"
	${VSReporter} = "${PSScriptRoot}/lib/vs_reporter.js"
	
	$arguments = @()
	$arguments += ${PathList}
	
	if (${CustomConfigFile}) {
		$arguments += @('--config', ${CustomConfigFile})
	}

	# Use VS reporter by default.
	if (!${CustomReporter} -and !${JSLintReporter}) {
		$arguments += @('--reporter', ${VSReporter});
	}
	
	if (${CustomReporter}) {
		$arguments += @('--reporter', ${CustomReporter})
	}
	
	if (${JSLintReporter}) {
		$arguments += '--jslint-reporter'
	}
	
	Write-Verbose "Running JSHint: `n${JSHint} ${arguments}"
	
	if (${ReportFile}) {
		(& ${JSHint} $arguments) | Tee-Object -Variable ReportFileContent
	} else {
		(& ${JSHint} $arguments)
	}
	$jshintExitCode = $LASTEXITCODE
	
	if (${ReportFile}) {
		Out-File -InputObject ${ReportFileContent} -FilePath ${ReportFile} -Encoding UTF8
	}
	
	if ($jshintExitCode -ne 0) {
		Write-Error -Message 'JSHint returned nonzero exit code.'
	}
}

Export-ModuleMember Invoke-JSHint
