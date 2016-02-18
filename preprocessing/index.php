<?php
include_once "./functions.php";


echo "<pre>";

error_reporting(E_ALL);
ini_set('display_errors', true);

$filepath           = "email";
$invalidEmailsPath  = "_invalid_emails";
$invalidDomainsPath = "_invalid_domains";
//$validEmailsPath    = "_valid_emails";



echo "Preprocessing start...<br/>";

echo "Files division start...<br/>";
$filesArr = separateDomains($filepath, $invalidEmailsPath);
echo "Email list was divided into the " . count($filesArr). " files...<br/>";


$i = 0;
foreach ($filesArr as $file => $domain) {
    echo "File " . ++$i . " : " . $file . "<br/>";
    $handle = fopen($file, "r");
    if ($handle) {
        // check domain. If not valid => pass this file
        if (!checkdnsrr($domain, 'MX')) {
            echo "ERROR: Domain is not valid : $domain <br/>";
            file_put_contents($invalidDomainsPath, $domain."\n", FILE_APPEND | LOCK_EX);
            // write all emails from this file to invalid_mails
            mergeFiles($invalidEmailsPath, $file);
            // remove $file
            fclose($handle);
            unlink($file);
            echo "File was removed<br/><br/>";
            continue;
        }
        fclose($handle);
        echo("Finished : " . $file . "<br/><br/>");
    } else {
        echo("ERROR: Can't open file : " . $file . "<br/><br/>");
    }
}


echo "Preprocessing done...<br/>";

echo "</pre>";