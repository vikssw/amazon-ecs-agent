# Copyright 2014-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may
# not use this file except in compliance with the License. A copy of the
# License is located at
#
#	http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

Param (
  [string]$BaseImageName="microsoft/windowsservercore"
)

# Prepare windows base image
$dockerImages = Invoke-Expression "docker images"
if (-Not ($dockerImages -like "*$BaseImageName*")) {
  Invoke-Expression "docker pull $BaseImageName"
}
Invoke-Expression "docker tag $BaseImageName amazon-ecs-ftest-windows-base:make"

# Prepare dependencies
Invoke-Expression "${PSScriptRoot}\..\misc\volumes-test\build.ps1"
Invoke-Expression "${PSScriptRoot}\..\misc\image-cleanup-test-images\build.ps1"
Invoke-Expression "${PSScriptRoot}\..\misc\stats-windows\build.ps1"
Invoke-Expression "${PSScriptRoot}\..\misc\container-health-windows\build.ps1"
Invoke-Expression "${PSScriptRoot}\..\misc\netkitten\build.ps1"

# Run the tests
$cwd = (pwd).Path
try {
  cd "${PSScriptRoot}"
  go test -race -tags integration -timeout=40m -v ../agent/engine ../agent/stats ../agent/app
  $testsExitCode = $LastExitCode
} finally {
  cd "$cwd"
}

exit $testsExitCode
