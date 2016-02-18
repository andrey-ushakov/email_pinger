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



echo "Preprocessing start...<br/>";

// 1. Exclude incorrect email formats. Separate by domains.
echo "Files division start...<br/>";
$filesArr = separateDomains($filepath, $invalidEmailsPath, $pathprefix);
echo "Email list was divided into the " . count($filesArr). " files...<br/>";


// 2. Remove incorrect domains
$i = 0;
$invalidDomainsCount = 0;
foreach ($filesArr as $file => $domain) {
    echo "File " . ++$i . " : " . $file . "<br/>";

    if (!checkdnsrr($domain, 'MX')) {
        echo "ERROR: Domain is not valid : $domain <br/>";
        $invalidDomainsCount++;
        file_put_contents($invalidDomainsPath, $domain."\n", FILE_APPEND | LOCK_EX);
        // write all emails from this file to invalid_mails
        mergeFiles($invalidEmailsPath, $file);
        // remove $file
        unlink($file);
        echo "File was removed<br/><br/>";
        continue;
    }
    echo("Finished : " . $file . "<br/><br/>");
}


echo "Preprocessing done...<br/>";
echo "Total domains found : ". count($filesArr) . "<br/>";
echo "Invalid domins : $invalidDomainsCount<br/>";

echo "</pre>";