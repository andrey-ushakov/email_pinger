set timeout 10

set filename    [lindex $argv 0]
set domain      [lindex $argv 1]
set hostName    [lindex $argv 2]
set emailFrom   [lindex $argv 3]
set heloDomain  [lindex $argv 4]


proc pingEmail {email pathValid pathInvalid domain emailFrom heloDomain} {
    send "HELO $heloDomain\r"
    expect {
        -re "(^|\n)250.*" { }
        -re "(^|\n)5\[0-9]\[0-9].*" {print_problem_domain 1$domain $expect_out(0,string) $expect_out(buffer)
                          expect *
                          exit 2}
    }

    send "MAIL FROM:<$emailFrom>\r"
    expect {
        -re "(^|\n)250.*" { }
        -re "(^|\n)5\[0-9]\[0-9].*" {print_problem_domain 2$domain $expect_out(0,string) $expect_out(buffer)
                          expect *
                          exit 2}
    }


    send "RCPT TO:<$email>\r"
    expect {
        -re "(^|\n)250.*" {
            send_user "\n\n $email : VALID \n\n"

            set validOut    [open $pathValid a]
            puts $validOut $email
            close $validOut
        }
        -re "(^|\n)550 5.7.1 Service unavailable.*" {print_problem_domain 3$domain $expect_out(0,string) $expect_out(buffer)
                         exit 2}
        -re "(^|\n)550.*" {
            send_user "\n\n $email : INVALID \n\n"

            set invalidOut  [open $pathInvalid a]
            puts $invalidOut $email
            close $invalidOut
        }

        -re "(^|\n)5\[0-9]\[0-9].*" {print_problem_domain 3$domain $expect_out(0,string) $expect_out(buffer)
                          expect *
                          exit 2}
    }
}



proc print_problem_domain {domain message message2} {
    set path _problem_domains
    set fileOut  [open $path a]
    puts $fileOut "$domain >>> $message\n\n\n"
    close $fileOut
}


send_user "............Starting expect............\n"

#expect {
#    timeout  { puts "timed out during login"; exit 1 }
#}

# Get the list of emails, one per line #####
set f [open $filename]
set emails [split [read $f] "\n"]
close $f

# Create output files
#set pathValid   valid_$domain
#set pathInvalid invalid_$domain
set pathValid   _valid_emails
set pathInvalid _invalid_emails


# Start telnet
spawn torify wget http://ipinfo.io/ip -qO -
expect  { * send_user Public ip: $expect_out(0,string) }

spawn torify telnet $hostName 25
expect -re ".*Trying"

expect {
    -re "(^|\n)220.*" {
        # Iterate over the emails
        foreach email $emails {
            if { [ string length $email ] != 0 } {      # email length != 0
                pingEmail $email $pathValid $pathInvalid $domain $emailFrom $heloDomain
                #send_user "$email\n"
            }
            
        }
    }
    -re "(^|\n)5\[0-9]\[0-9].*" {print_problem_domain 4$domain $expect_out(0,string) $expect_out(buffer)
                          expect *
                          exit 2}
    timeout  { send_user "Timed out during telnet\n"; exit 1 }
}


send_user "............Ending expect............\n"

exit 0