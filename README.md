Usage: sudo bash bash.sh "path/to/domain_*/files"

1. PHP Preprocessing

Input:
- File named "emails". Each line has one email address to check.

Usage: \<your_server\>/preprocessing/index.php?dataPath=\<path_to_folder_with_emails_file\>
- Exclude incorrect email formats
- Group emails into separated files by domains
- Remove invalid domains
- Place file domains into folders

Output:
- File _invalid_emails
- File _invalid_domains
- Emails grouped by folders

2. Run pingers

Usage: sudo bash runPingers.sh \<path_to_data\<N\>_directory\>

Output:
- Checks emails in dataNdirectory
- File _log
- File _valid_emails
- File _invalid_emails
- File _problem_domains
- File _invalid_domains
- Domain file that wasn't checked


3. Merge files & remove temp files

Usage (merge): sudo bash mergeResults.sh \<path_to_data_directory\>
Usage (remove temp files): sudo bash removeMergedInputs.sh \<path_to_data_directory\>

Output:
- Final _valid_emails file
- Final _invalid_emails file
- Final _invalid_domains file
