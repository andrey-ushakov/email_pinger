<?php
function separateDomains($filepath, $invalidEmailsPath, $pathprefix) {
    $filesArr = array();
    //$listSize = count(file($filepath));
    $handle = fopen($filepath, "r");
    //$i = 0;
    if ($handle) {
        while (($email = fgets($handle)) !== false) {
            $email = trim($email);
            // Check email format
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                file_put_contents($invalidEmailsPath, $email."\n", FILE_APPEND | LOCK_EX);
            } else {
                $arr = explode("@", $email);
                $domain = array_pop($arr);
                $fileOut = $pathprefix."domain_" . $domain;
                file_put_contents($fileOut, $email."\n", FILE_APPEND | LOCK_EX);
                $filesArr[$fileOut] = $domain;
            }
        }
    } else {
        return false;
    }

    fclose($handle);
    return $filesArr;
}



function mergeFiles($toFile, $fromFile) {
    $handleFrom = fopen($fromFile, "r");
    if ($handleFrom) {
        $linesCnt = 0;
        while (($line = fgets($handleFrom)) !== false) {
            $linesCnt++;
            file_put_contents($toFile, $line, FILE_APPEND | LOCK_EX);
        }
    } else {
        return 0;
    }
    return $linesCnt;
}


function createDir($dirPath) {
    $oldmask = umask(0);
    mkdir($dirPath, 0777);
    umask($oldmask);
}