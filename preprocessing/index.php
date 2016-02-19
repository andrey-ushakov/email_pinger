<?php
include_once "./functions.php";


date_default_timezone_set('Europe/Paris');
$timestart          =   microtime(true);

error_reporting(E_ALL);
ini_set('display_errors', true);

if(!isset($_GET["dataPath"])) {
    echo "ERROR: dataPath wasn't provided";
    exit;
}
$pathprefix = $_GET["dataPath"];


echo "<pre>";

//$pathprefix         = "../data/";
$filepath           = $pathprefix."emails";
$invalidEmailsPath  = $pathprefix."_invalid_emails";
$invalidDomainsPath = $pathprefix."_invalid_domains";
//$validEmailsPath    = "_valid_emails";
$maxEmailsNumInFolder     =   5000;


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
$emailsNumInFolderArr   = array();

// create src1 dir
createDir($pathprefix."src$folderInd");
$emailsNumInFolderArr[$pathprefix."src$folderInd"] = 0;

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
        $curFolderName = $pathprefix."src$folderInd";

        if($emailsNumInFolderArr[$curFolderName] >= $maxEmailsNumInFolder) {
            $folderInd++;
            $curFolderName = $pathprefix."src$folderInd";
            $emailsNumInFolderArr[$curFolderName] = 0;
            createDir($pathprefix."src$folderInd");
        }
        // replace file
        $linesCnt = count(file($file));
        rename($file, "$curFolderName/".basename($file));
        chmod("$curFolderName/".basename($file), 0777);
        $emailsNumInFolderArr[$curFolderName] += $linesCnt;
        echo "Placed to folder : $curFolderName/ <br/>";
    }
    echo("Finished<br/><br/>");
}


echo "Preprocessing done...<br/>";
echo "Total domains found : $totalDomainsCount <br/>";
echo "Invalid domains : $invalidDomainsCount <br/><br/>";

echo "Emails num in folders: <br/>";
print_r($emailsNumInFolderArr);


// Execution time
$timeend    =   microtime(true);
$time       =   $timeend-$timestart;
$page_load_time = number_format($time, 3);
echo "Script started at: ".date("H:i:s", $timestart);
echo "<br>Script finished at: ".date("H:i:s", $timeend);
echo "<br>Execution time: " . $page_load_time . " sec";

echo "</pre>";