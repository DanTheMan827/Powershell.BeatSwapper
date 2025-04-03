# Check if the script received exactly 3 arguments
if ($args.Count -ne 3) {
    Write-Output "Usage: ./beatswapper.ps1 <SourceFile> <DestinationID> <DestinationFile>"
    Write-Output "Example: ./beatswapper.ps1 com.beatgames.beatsaber.apk com.beatgames.beatsabercopy com.beatgames.beatsabercopy.apk"
    exit 1
}

# Assign arguments to variables
$SourceFile = $args[0]
$destinationPackageName = $args[1]
$DestinationFile = $args[2]

# Check if the SourceFile exists
if (-Not (Test-Path -Path $SourceFile)) {
    Write-Output "Error: Source file '$SourceFile' does not exist."
    exit 1
}

# Check if we can run java
if (-Not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Output "Error: Java is not installed or not in the system PATH."
    exit 1
}

# Ensure the source and destination file paths are both .apk files (case insensitive)
if ($SourceFile.ToLower() -notmatch '\.apk$' -or $DestinationFile.ToLower() -notmatch '\.apk$') {
    Write-Output "Error: Source and destination files must have a .apk extension."
    exit 1
}

# Set our key base64 string
$keyBase64 = @"
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCG91Pzd8S07JnX
vp19mewAXPhDLCvdsOTdK5/8pwBPt0Mr2+J2OqhQbD9S6j9bjWcjKGTpvvDKkltM
xbBAARM5FprtQIXnJeiSA6o0m2po/iJGWSxSAlINNFCMOVydf7qto19oZJ3P6j6x
jbL5bYGeTQ8CHP3jSe0m9W/D2A9ax1jBL8ZHQ5luNRFD9+Y+TQEyV9jY0At0GQLJ
W5E/PdE65cDVm3sWtWMqUknt9YY2k2FXPLm7KGnBqv3UsQJDnxCmH9flPs9FXcbu
+sEp3zux/0lz2HOE6Dc86KpNJKPSwc406pXtbBxCQQikQWzCrUMpc+K48jKG74CB
ZD6hcunfAgMBAAECggEABMpzZ262mSQrkytH/zUJ2eVy8TzN0yZmqVcqwawn6Fco
Aj7hkLLPq13RovQqYD8/tvwbFj+vNRxG3g3HuNiQ7HOEolaqVM8qrJbcDCwBdff3
aCndgeJlM+TJ1dW/bN541kBjWvBKDcmnL2RJQxiuWNvWuYt6k6kvIDU8IhE2/PuN
et5dVNmVo6ZRRdPi0Z4k1eAyx4njWzPMGYHk66ujiCirHaNOQbHqpf9Ge8ij+GnT
KQdJA62DcXW2ZxiLmqUrCagWWfelGE3bsR0lQ5oBXtp2/T2HIzrJGiyDQDjtpsUc
gEEKqC92Oo2T6ituhSOF88dpvC3rHSKZnWS/iLBQ2QKBgQD107uXUioYnV9KVDDD
LkdEHyZvmzjzwbWxRObFHoHI+vaB/uHoWZe8bXJBncDo4tUUeQVFr75sZ1neeBbq
+dCGZ+kBVoCODcSR2UA3V5XIR8AKSShhXbQPg+YzTsH1o4YpcrQqm/BiHwaVkMq4
ogLxDKYuUPE7D9QkiYWf/h1oiwKBgQCMjSU5DtKUq91qVizR+k+jeBmbKAV6ix80
UnXHAPGHOgG9SGQd8eGjqoGPvBvYThSMdALrtCCdB7rRJCekH8t+YKT0e9Dh0HSQ
IaGgce6FQf0p/09fpq4obJI1nqnuAbzE7L10GMwfvmAkrcf8uxbssREIMeZp59Ln
d/VCl8JafQKBgHHHLxMpr1w3MoyXjP45pDiOZl7PrDt+E9dZeaoQpaddKM0gKHU/
SnCnA3QFTO09V7wjC2Kmpe9MopbKZGkbeP1MiNbar6OQEcQjlopG2oeZVfQsyijO
kvF/bgOfVzyXFBiJA4SZKlhv3b9KBdoQ+mWRIjVbt1tLxzemAxf7KKdjAoGAGGdN
ZjnHoF6y5AqwX4j5mOV6dLEfOma7dUc4AeSNCzCsKqROFdDwn400T7OWlhkAgl6G
P0yYOQuliTig1WNb3saC/Zwd6YdbJcdhG82MX4DUpx0YOABlzskDHeI9mQCeOQbt
4iGIF57jbJrr1VraoSAhV+3qFstUmDIA2J4m9bUCgYEA1f/tmkdk7pQpvwoGzzVo
yfWbDjvyndHgGuNoGH/0KaH3xSPHOA2j34pDAD3tCAuFl3keMulmUTNXjmA7hVqQ
ACdcO0IRYQw/LY+n86j6TDmzOexR70OToDSWUBjzFdUyJh7IduhfEM84IfzLVOAR
bQ1zZyecIo66OLbBojCtXBE=
"@

# Set our certificate data
$certData = @"
-----BEGIN CERTIFICATE-----
MIICpjCCAY6gAwIBAgIIcmOVkuI/DbUwDQYJKoZIhvcNAQELBQAwEjEQMA4GA1UE
AwwHVW5rbm93bjAgFw0xMTA5MjkwMDAwMDBaGA8yMDcxMDkyOTAwMDAwMFowEjEQ
MA4GA1UEAwwHVW5rbm93bjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AIb3U/N3xLTsmde+nX2Z7ABc+EMsK92w5N0rn/ynAE+3Qyvb4nY6qFBsP1LqP1uN
ZyMoZOm+8MqSW0zFsEABEzkWmu1Ahecl6JIDqjSbamj+IkZZLFICUg00UIw5XJ1/
uq2jX2hknc/qPrGNsvltgZ5NDwIc/eNJ7Sb1b8PYD1rHWMEvxkdDmW41EUP35j5N
ATJX2NjQC3QZAslbkT890TrlwNWbexa1YypSSe31hjaTYVc8ubsoacGq/dSxAkOf
EKYf1+U+z0Vdxu76wSnfO7H/SXPYc4ToNzzoqk0ko9LBzjTqle1sHEJBCKRBbMKt
Qylz4rjyMobvgIFkPqFy6d8CAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAMNTQo9lg
bvHnp1Ot4g1UgjpSDu52BKdAB0eaeR/3Rtm+E0E+jUMXSI70im4PxbN+eOmTG3NC
o0nO/FLQUw3j3o3kmON4VlPapGsDpKe2rHbL+5HySPbSjkGpwTTGPVzzfhv9dUD6
l97QIB5cmvRH3T9CP/8c+erOARBF2kGitdNTtyUxvQsl/xaiKAnuaE7Ub0YmpsZQ
e1EiJ9LNwF92YvK3dWP9cBKOKnxQEAcSgugGWWIbiCWF9KHLUWYvT2Gv1tgl+kvE
/ZUie++OqnFEjPeWDTsbpiJXD1sKFUp3iCf970mgLMfXYwkiRxwicYFny0tu90wF
Nbzwy1zKhUC80w==
-----END CERTIFICATE-----
"@

# Log our parameters
Write-Output "I: Source file is $SourceFile"
Write-Output "I: New package name is $destinationPackageName"
Write-Output "I: Destination file is $DestinationFile"

# Create a temporary directory
Write-Output "I: Creating temporary directory..."
$tempDir = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())) -Force
Write-Output "I: Temporary directory created at $($tempDir.FullName)"

# Setup our tool paths
$apktool = Join-Path $PSScriptRoot "apktool.jar"
$apksigner = Join-Path $PSScriptRoot "apksigner.jar"

# Log the paths to the tools
Write-Output "I: apktool path is $apktool"
Write-Output "I: apksigner path is $apksigner"

# Assign the unpacked directory path
$unpackedDir = Join-Path $tempDir.FullName "unpacked"

# Use apktool to decompile the APK file
Write-Output "I: Unpacking APK file to $unpackedDir..."
& java -jar "$apktool" d "$SourceFile" -o "$unpackedDir"

# Set the path to the AndroidManifest.xml file
$manifestPath = Join-Path $unpackedDir "AndroidManifest.xml"

# Read and parse the manifest file and extract the package name
Write-Output "I: Reading AndroidManifest.xml..."
$manifestContent = Get-Content -Path $manifestPath -Raw
$xml = [xml]$manifestContent
$sourcePackageName = $xml.manifest.package
Write-Output "I: Source package name is $sourcePackageName"

# Split the package name by dots
$sourcePackageParts = $sourcePackageName -split '\.'

# Split the destination package name by dots
$destinationPackageParts = $destinationPackageName -split '\.'

# Set the path to the smali directory
$smaliDir = Join-Path $unpackedDir "smali"

# Create a source smali path by joining the smali directory with the package parts through a loop
$sourceSmaliPath = $smaliDir
foreach ($part in $sourcePackageParts) {
    $sourceSmaliPath = Join-Path $sourceSmaliPath $part
}

Write-Output "I: Source smali path is $sourceSmaliPath"

# Create a destination smali path by joining the smali directory with the package parts through a loop
$destinationSmaliPath = $smaliDir
foreach ($part in $destinationPackageParts) {
    $destinationSmaliPath = Join-Path $destinationSmaliPath $part
}

Write-Output "I: Destination smali path is $destinationSmaliPath"

# Create the parent directory for the destination smali path if it doesn't exist
$destinationParentDir = Split-Path -Path $destinationSmaliPath -Parent
if (-Not (Test-Path -Path $destinationParentDir)) {
    Write-Output "I: Creating destination smali parent directory at $destinationParentDir..."
    New-Item -ItemType Directory -Path $destinationParentDir -Force | Out-Null
}

# Move the source smali directory to the destination smali directory
Write-Output "I: Moving smali files from $sourceSmaliPath to $destinationSmaliPath..."
Move-Item -Path $sourceSmaliPath -Destination $destinationSmaliPath | Out-Null

# Create variables for the source and destination smali class names joined by /
$sourceSmaliClassName = $sourcePackageParts -join "/"
$destinationSmaliClassName = $destinationPackageParts -join "/"

# Replace all occurrences of the source package name with the destination package name in the smali files and AndroidManifest.xml
$smaliFiles = Get-ChildItem -Path $smaliDir -Recurse -File -Filter "*.smali"
foreach ($file in $smaliFiles) {
    $content = Get-Content -Path $file.FullName -Raw

    if ($content.Contains($sourceSmaliClassName) -or $content.Contains($sourcePackageName)) {
        Write-Output "I: Replacing package name in $($file.FullName)..."
        $content = $content.Replace($sourceSmaliClassName, $destinationSmaliClassName)
        $content = $content.Replace($sourcePackageName, $destinationPackageName)
        $content | Set-Content -Path $file.FullName
    }
}

# Replace the package name in the AndroidManifest.xml file
Write-Output "I: Replacing package name in AndroidManifest.xml..."
(Get-Content -Path $manifestPath -Raw).Replace($sourcePackageName, $destinationPackageName) | Set-Content -Path $manifestPath

# Recompile the APK file using apktool
$intermediateFile = Join-Path $tempDir.FullName "intermediate.apk"
Write-Output "I: Recompiling APK file to $intermediateFile..."
& java -jar "$apktool" b "$unpackedDir" -o "$intermediateFile"

# Remove the unpacked directory
Write-Output "I: Cleaning up unpacked files..."
Remove-Item -Path $unpackedDir -Recurse -Force

# Set our key and certificate paths
$keyPath = Join-Path $tempDir.FullName "debug_key.pk8"
$certPath = Join-Path $tempDir.FullName "debug_cert.crt"

# Decode and write our key to a file
Write-Output "I: Writing key to $keyPath..."
[System.Convert]::FromBase64String($keyBase64) | Set-Content -Path $keyPath -AsByteStream

# Write our certificate to a file
Write-Output "I: Writing certificate to $certPath..."
$certData | Set-Content -Path $certPath

# Sign the APK file using apksigner
Write-Output "I: Signing APK file with apksigner..."
& java -jar "$apksigner" sign --key "$keyPath" --cert "$certPath" "$intermediateFile"

# Move the signed APK to the destination file path
Write-Output "I: Moving signed APK to $DestinationFile..."
Move-Item -Path $intermediateFile -Destination $DestinationFile -Force

# Remove our temporary directory
Write-Output "I: Cleaning up temporary files..."
Remove-Item -Path $tempDir.FullName -Recurse -Force
