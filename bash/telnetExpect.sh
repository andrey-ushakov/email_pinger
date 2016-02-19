set timeout 10

set filename    [lindex $argv 0]
set domain      [lindex $argv 1]
set mxAddr      [lindex $argv 2]
set basePath    [lindex $argv 3]

proc randomRangeString {length {chars "abcdefghijklmnopqrstuvwxyz"}} {
    set range [expr {[string length $chars]-1}]

    set txt ""
    for {set i 0} {$i < $length} {incr i} {
       set pos [expr {int(rand()*$range)}]
       append txt [string range $chars $pos $pos]
    }
    return $txt
}


proc pingEmail {email pathValid pathInvalid domain basePath} {
    set emailFrom [randomRangeString 10]@gmail.com
    set heloDomain [randomRangeString 10].com

    send "HELO $heloDomain\r"
    expect {
        timeout  { send_user "Timed out during telnet\n"; exit 1 }
        -re "(^|\n)250.*" { }
        -re "(^|\n)\[0-9]\[0-9]\[0-9].*" {print_problem_domain ${domain}(1) $expect_out(0,string) $basePath
                          expect *
                          exit 2}
    }

    send "MAIL FROM:<$emailFrom>\r"
    expect {
        timeout  { send_user "Timed out during telnet\n"; exit 1 }
        -re "(^|\n)250.*" { }
        -re "(^|\n)\[0-9]\[0-9]\[0-9].*" {print_problem_domain ${domain}(2) $expect_out(0,string) $basePath
                          expect *
                          exit 2}
    }


    send "RCPT TO:<$email>\r"
    expect {
        timeout  { send_user "Timed out during telnet\n"; exit 1 }
        -re "(^|\n)250.*" {
            send_user "\n\n $email : VALID \n\n"

            set validOut    [open $pathValid a]
            puts $validOut $email
            close $validOut
        }

        -re "(^|\n).*Service unavailable.*" {print_problem_domain ${domain}(3) $expect_out(0,string) $basePath
                                 exit 2}
        -re "(^|\n).*poor sender reputation.*" {print_problem_domain ${domain}(3) $expect_out(0,string) $basePath
                                 exit 2}

        -re "(^|\n)550.*" {
            send_user "\n\n $email : INVALID \n\n"

            set invalidOut  [open $pathInvalid a]
            puts $invalidOut $email
            close $invalidOut
        }

        -re "(^|\n)\[0-9]\[0-9]\[0-9].*" {print_problem_domain ${domain}(3) $expect_out(0,string) $basePath
                          expect *
                          exit 2}
    }
}



proc print_problem_domain {domain message basePath} {
    set path ${basePath}_problem_domains
    set fileOut  [open $path a]
    puts $fileOut "$domain >>> $message\n\n"
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
set pathValid   ${basePath}_valid_emails
set pathInvalid ${basePath}_invalid_emails

# Start telnet
#spawn torify wget http://ipinfo.io/ip -qO -
#expect  { * send_user Public ip: $expect_out(0,string) }

spawn torify telnet $mxAddr 25
#expect -re ".*Trying"

expect {
    timeout  { send_user "Timed out during telnet\n"; exit 1 }

    -re "(^|\n)220.*" {
        # Iterate over the emails
        foreach email $emails {
            if { [ string length $email ] != 0 } {      # email length != 0
                pingEmail $email $pathValid $pathInvalid $domain $basePath
                #send_user "$email\n"
            }
            
        }
    }
    -re "(^|\n)5\[0-9]\[0-9].*" {print_problem_domain ${domain}(4) $expect_out(0,string) $basePath
                          expect *
                          exit 2}
    -re "ERROR torsocks.*" {print_problem_domain ${domain}(4) $expect_out(0,string) $basePath
                          expect *
                          exit 2}
    -re "telnet: could not resolve.*"{print_problem_domain ${domain}(4) $expect_out(0,string) $basePath
                           expect *
                           exit 2}

}


send_user "............Ending expect............\n"

exit 0