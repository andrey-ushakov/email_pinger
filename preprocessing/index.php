<?php
include_once "./functions.php";


echo "<pre>";

error_reporting(E_ALL);
ini_set('display_errors', true);

$pathprefix         = "../data/";
$filepath           = $pathprefix."email";
$invalidEmailsPath  = $pathprefix."_invalid_emails";
$invalidDomainsPath = $pathprefix."_invalid_domains";
//$validEmailsPath    = "_valid_emails";
$emailsInFolder     =   200;


echo "Preprocessing start...<br/>";

// 1. Exclude incorrect email formats. Separate by domains
echo "Files division start...<br/>";
$filesArr = separateDomains($filepath, $invalidEmailsPath, $pathprefix);
$totalDomainsCount = count($filesArr);
echo "Email list was divided into the $totalDomainsCount files...<br/>";


// 2. Remove invalid domains & Place domains in folders
$i                      = 0;
$invalidDomainsCount    = 0;

$folderInd              = 1;
$emailsInCurFolder      = 0;
mkdir($pathprefix."src$folderInd");
foreach ($filesArr as $file => $domain) {
    echo "File " . ++$i . " : " . $file . "<br/>";

    // 2. Remove invalid domains
    if (!checkdnsrr($domain, 'MX')) {
        echo "ERROR: Domain is not valid : $domain <br/>";
        $invalidDomainsCount++;
        file_put_contents($invalidDomainsPath, $domain."\n", FILE_APPEND | LOCK_EX);
        // write all emails from this file to invalid_mails
        mergeFiles($invalidEmailsPath, $file);
        // remove $file
        unlink($file);
    }
    // 3. Place domains in folders
    else {
        if($emailsInCurFolder >= $emailsInFolder) {
            $folderInd++;
            $emailsInCurFolder = 0;
            mkdir($pathprefix."src$folderInd");
        }
        $curFolderName = $pathprefix."src$folderInd";
        // replace file
        $linesCnt = count(file($file));
        rename($file, "$curFolderName/".basename($file));
        chmod("$curFolderName/".basename($file), 0777);
        $emailsInCurFolder += $linesCnt;
        echo "Placed to folder : $curFolderName/ <br/>";
    }
    echo("Finished<br/><br/>");
}


echo "Preprocessing done...<br/>";
echo "Total domains found : $totalDomainsCount <br/>";
echo "Invalid domins : $invalidDomainsCount <br/>";




echo "</pre>";