properties {	
	${test.broken.js} = "${src.dir}/test/broken.js"
	${test.correct.js} = "${src.dir}/test/correct.js"
	${test.testfile.js} = "${src.dir}/test/testfile.js"
	
	$tests = @(
		'test-no-error-when-no-errors-found',
		'test-raises-error-when-errors-found',
		'test-uses-VS-reporter-by-default',
		'test-writes-report-file',
		'test-uses-config-file-when-specified',
		'test-uses-default-reporter-when-specified',
		'test-uses-jslint-reporter-when-specified')
}

task run-tests {	
	$errors = 0
		
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
					Write-Host -ForegroundColor Red -Object $_
					$errors = $errors + 1
				}
			}
	} finally {
		Remove-Module jshint -ErrorAction SilentlyContinue
	}
    
	if ($errors -gt 0) {
		Write-Error -Message "Failed tests: $errors"
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

function test-uses-default-reporter-when-specified {
	$actual = Invoke-JSHint -PathList "${src.dir}/test/broken.js" -ReporterType Default -ErrorAction SilentlyContinue
	$expected = "./src/test/broken.js: line 1, col 14, Unmatched '{'.  1 error"
	Assert (($actual -join " ") -eq $expected) "Expected: '${expected}'`n`tbut got:  '${actual}'"
}

function test-uses-jslint-reporter-when-specified {
	$actual = Invoke-JSHint -PathList "${src.dir}/test/broken.js" -ReporterType JSLint -ErrorAction SilentlyContinue
	$expected = "<?xml version=""1.0"" encoding=""utf-8""?> <jslint> `t<file name=""src/test/broken.js""> `t`t<issue line=""1"" char=""14"" reason=""Unmatched &apos;{&apos;."" evidence=""function a() {"" /> `t</file> </jslint>"
	Assert (($actual -join " ") -eq $expected) "Expected: '${expected}'`n`tbut got:  '${actual}'"
}
