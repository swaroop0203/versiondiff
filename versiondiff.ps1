[CmdletBinding()]
param (
[Parameter(Mandatory=$True,Position=1)]
[string]$version1,
[Parameter(Mandatory=$True,Position=2)]
[string]$version2,
[Parameter(Mandatory=$False,Position=3)]
[string]$htmlreport,
[Parameter(Mandatory=$False)]
[string]$plant
)

#Check to see if parameters are passed correctly
if($PSBoundParameters.Count -lt 2)
{
    echo " usage example:  versiondiff.ps1 1.1.1.0 2.2.2.0 or versiondiff.ps1 1.1.1.0 2.2.2.0 html"
    exit
}

#Set plantname as the repo directory name
if(!$plant)
{
    $plant = 'plant-deployment'
}

#Variables
$cr_dir = $PSScriptRoot
$pd_dir = $PSScriptRoot + "\$plant"
$pd_repo = "git@gitlab.com:vistaprint-org/manufacturing-software/viper/plant-deployment.git"
$finaldiff = @()

# check for plant deployment repo and clone it if needed
if(!(Test-Path $pd_dir))
{
    git clone -n $pd_repo $pd_dir --quiet 2>$null
}

#If repo exists update the repo
else
{
    #git -C $pd_dir pull --quiet 2>$null
    git -C $pd_dir fetch --quiet 2>$null
    if(!$?)
        {
            Remove-Item -Recurse -Force $pd_dir
            git clone -n $pd_repo $pd_dir
        }
}

#Correcting the order of versions
if(([int]($version1.Split(".")[3])) -gt ([int]($version2.Split(".")[3] )))
{
    $tempversion = $version1
    $version1 = $version2
    $version2 = $tempversion
}

#########################Validate the version function#################################################
function validate_version {
    Param (
    [string]$version
    )
    Process{
        $a = git -C $pd_dir rev-parse $version --quiet 2>$null
        if($?)
        {
            return "true"
        }
        else
        {
            return "false"
        }
    }
}

#Validate the versions
$isVersion1Valid = validate_version $version1
$isVersion2Valid = validate_version $version2

#If versions are valid compare the diff
if ( ($isVersion1Valid -eq "true") -and ($isVersion2Valid -eq "true") )
{
    # Get the diff between two versions
    $diffGitlab = git -C $pd_dir diff $version1 $version2 -- manifest.xml
    $leftlist = @()
    $rightlist = @()

    ForEach ($line in $diffGitlab)
    {
        #anything starting with - add them to leftlist
        if (($line.startswith('-')) -and ($line -notlike "*manifest.xml*" ) -and ($line -notlike "*<!--*" )  -and ($line -notlike "*packages>*" ) )
        {
            $leftlist += $line
        }
        #anything starting with - add them to rightlist
        if (($line.startswith('+')) -and ($line -notlike "*manifest.xml" -and ($line -notlike "*<!--*" ) ) -and ($line -notlike "*packages>*" ) )
        {
            $rightlist += $line
        } 
    }
    
    #Find the newversion for the each package in left list
    ForEach  ($leftline in $leftlist)
    {
        $leftline = $leftline.replace("-", "")
        #convert to xml and read the data
        $leftstr = [xml]$leftline
        $oldversion = $leftstr.package.version
        $leftpackageid = $leftstr.package.id
        
        ForEach ($rightline in $rightlist)
        {
            if ($rightline -like "*$leftpackageid*")
            {
                $rightline = $rightline.replace("+", "")
                $rightstr = [xml]$rightline
                $newversion = $rightstr.package.version
                #Write $finaldiff array with all package ids from diff
                $finaldiff += "$leftpackageid : $oldversion : $newversion"
            }
        }
    }
}
else
{
    echo "Provided versions are not valid"
    exit
}
# Write the final outputstring which will be printed at the end and is the main output of versiondiff.
if( $htmlreport.ToLower() -eq "html" )
{
    $outputString = @()
    $outputString += "<table><tr><th>{0}</th><th>{1}</th><th>{2}</th></tr>"  -f "CurrentDeployedVersion -> NewVersion", $version1, $version2;
    if ( $finaldiff.count -gt 0 )
    {
        ForEach  ($finaldiffline in $finaldiff) {
            $outputString += "<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>"  -f $finaldiffline.Split(":")[0] , $finaldiffline.Split(":")[1], $finaldiffline.Split(":")[2]
        }
    }
    $outputString += "</table><br>";
}
else
{
    $outputString = @()
    $outputString += "----------------------------------------------------------------------";
    $outputString += "{0,-40} {1,15} -> {2,-15} "  -f "CurrentDeployedVersion -> NewVersion" , $version1, $version2;
    $outputString += "----------------------------------------------------------------------";
    # Verify if finaldiff is empty and add each package details to output string
    if ( $finaldiff.count -gt 0 )
    {
        ForEach  ($finaldiffline in $finaldiff) {
            $outputString += "{0,-40} {1,15} -> {2,-15} "  -f $finaldiffline.Split(":")[0] , $finaldiffline.Split(":")[1], $finaldiffline.Split(":")[2]
        }
        $outputString += "----------------------------------------------------------------------";
    }
}
# Verify if it is major release
if(($version1.Split(".")[0,1,2] -join ".") -eq ($version2.Split(".")[0,1,2] -join "."))
{
    $outputString += "MajorRelease:False"
}
else
{
    $outputString += "MajorRelease:True"
}
# Print the final output.
echo $outputString
