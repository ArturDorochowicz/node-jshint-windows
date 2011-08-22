properties {	
	${test.broken.js} = "${src.dir}/test/broken.js"
	${test.correct.js} = "${src.dir}/test/correct.js"
	${test.testfile.js} = "${src.dir}/test/testfile.js"
	
	$tests = @(
		'test-no-error-when-no-errors-found',
		'test-raises-error-when-errors-found',
		'test-uses-VS-reporter-by-default',
		'test-writes-report-file',
		'test-uses-config-file-when-specified')
}

task run-tests {	
	$errors = @{}
		
	try {
		Remove-Module jshint -ErrorAction SilentlyContinue
		Import-Module "${build.dir}/cli/jshint.psm1"
		$tests |
			%{
				$test = $_
				"Test: $test"
				try {					
					& $test | Out-Null
					"      OK"
				} catch {
					"      Failed"
					$errors[$test] = $_
				}
			}
	} finally {
		Remove-Module jshint -ErrorAction SilentlyContinue
	}
		
	$errors.Keys | 
		%{
			$testFailure = $errors[$_]
			Write-Error -Message "Test: $_ failed:`n$testFailure"
		}
}

function test-no-error-when-no-errors-found {
	try {
		Invoke-JSHint -PathList ${test.correct.js}
	} catch {
		Assert $false "Expected no error to be raised"
	}
}

function test-raises-error-when-errors-found {
	try {
		Invoke-JSHint -PathList ${test.broken.js}
		Assert $false 'Expected error raised'
	} catch {
	}	
}

function test-uses-VS-reporter-by-default {
	$actual = Invoke-JSHint -PathList "${src.dir}/test/broken.js" -ErrorAction SilentlyContinue
	$expected = "./src/test/broken.js(1,14): error JSHint: Unmatched '{'."
	Assert ($actual -eq $expected) "Expected: '${expected}'`n`tbut got:  '${actual}'"
}

function test-writes-report-file {
	${report.file} = "${build.dir}/report.txt"
	try {
		Invoke-JSHint -PathList "${src.dir}/test/broken.js" -ReportFile ${report.file} -ErrorAction SilentlyContinue
		$actual = Get-Content -Path ${report.file}		
		$expected = "./src/test/broken.js(1,14): error JSHint: Unmatched '{'."
		Assert ($actual -eq $expected) "Expected: '${expected}'`n`tbut got:  '${actual}'"
	} finally {
		Remove-Item -Path ${report.file} -ErrorAction SilentlyContinue
	}
}

function test-uses-config-file-when-specified {
	${config.file} = "${src.dir}/test/config.json"
	$actual = Invoke-JSHint -PathList ${test.testfile.js} -ConfigFile ${config.file} -ErrorAction SilentlyContinue
	$expected = "./src/test/testfile.js(3,13): error JSHint: 'window' is not defined."
	Assert ($actual -eq $expected) "Expected: '${expected}'`n`tbut got:  '${actual}'"
}
