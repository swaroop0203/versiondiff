Versiondiff tool is used to find difference between versions of a release. It reads the manifest.xml file and lists the different services updated in the new release. 

Prerequisites:

Project should consist a manifest.xml with list of services and their current version.
example:
<packages>
  <package id="Data" version="100.0.719" />
  <package id="UI" version="2023.307.6" />
  <package id="IntegrationService" version="2.2.0" />
  <package id="TestFramework" version="2023.307.6" />
</packages>


Versiondiff repo consists of both powershell script and the website code.

Powershellscript - versiondiff.ps1
Website Code - versiondiff_website Folder

Version diff service is listening on port 1337 and service - VersionDiffPSSvc
