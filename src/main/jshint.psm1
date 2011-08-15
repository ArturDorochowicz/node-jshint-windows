Remove-Module JSHint -ErrorAction SilentlyContinue

function Invoke-JSHint {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)] [string[]] ${PathList},
		[string] ${CustomConfigFile},
		[string] ${CustomReporter},
		[switch] ${JSLintReporter},
		[string] ${ReportFile},
		[string] ${JSHint} = "${PSScriptRoot}/jshint.bat"
	)
	process {
		$arguments = @()
		$arguments += ${PathList}
		
		if (${CustomConfigFile}) {
			$arguments += @('--config', ${CustomConfigFile})
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
			& ${JSHint} $arguments
		}
		if ($LASTEXITCODE -ne 0) {
			$errorExitCode = $true
		}
		
		if (${ReportFile}) {
			Out-File -InputObject ${ReportFileContent} -FilePath ${ReportFile} -Encoding UTF8
		}
		
		if ($errorExitCode) {
			throw 'JSHint returned nonzero exit code.'
		}
	}
}

Export-ModuleMember Invoke-JSHint
