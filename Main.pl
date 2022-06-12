package KeyAuth;
require "./KeyAuth.pl";

KeyAuth::Api(
    "Application Name",
    "Application Owner ID",
    "Application Secret",
    "1.0"
);

KeyAuth::ClearConsole();
print "\n\n Initializing...\n";
KeyAuth::Init();

print("
 App data: 
 Number of users: " . $AppInfo{'numUsers'} . "
 Number of online users: " . $AppInfo{'numOnlineUsers'} . " 
 Number of keys: " . $AppInfo{'numKeys'} . "
 Application Version: " . $AppInfo{'version'} . "
 Customer panel link: " . $AppInfo{'customerPanelLink'} . "
");

print "\n [1] Login\n [2] Register\n [3] Upgrade\n [4] License key only\n\n Choose option: ";
$choice = <STDIN>;
chomp $choice;

if ($choice == "1") {
    print "\n Enter your username: ";
    $username = <STDIN>;
    chomp $username;
    print "\n Enter your password: ";
    $password = <STDIN>;
    chomp $password;
    
    KeyAuth::Login($username, $password);

} elsif ($choice == "2") {
    print "\n Enter your username: ";
    $username = <STDIN>;
    chomp $username;
    print "\n Enter your password: ";
    $password = <STDIN>;
    chomp $password;
    print "\n Enter your license: ";
    $license = <STDIN>;
    chomp $license;
    
    KeyAuth::Register($username, $password, $license);

} elsif ($choice == "3") {
    print "\n Enter your username: ";
    $username = <STDIN>;
    chomp $username;
    print "\n Enter your license: ";
    $license = <STDIN>;
    chomp $license;
    
    KeyAuth::Upgrade($username, $license);

} elsif ($choice == "4") {
    print "\n Enter your license: ";
    $license = <STDIN>;
    chomp $license;
    
    KeyAuth::License($license);

} else {
    print("\nNot Valid Option");
    exit(0);
}

print("
 User Data:

 Username: " . $user_data{'username'} . "
 IP address: " . $user_data{'ip'} . "
 Hardware-Id: " . $user_data{'hwid'} . " 
 Created at: " . UnixToDate($user_data{'createdate'}) . "
 Last login: " . UnixToDate($user_data{'lastlogin'}) . "

");

$SubsDecoded = decode_json(%user_data_Subscriptions);
my $Subs = $SubsDecoded;
my $SubsLength = scalar @$Subs;

print(" Your subscription(s):\n");

for ( my $i = 0; $i < $SubsLength; $i++ ) {
	print(" Subscription Name: $SubsDecoded->[$i]{'subscription'} - Expires: " . UnixToDate($SubsDecoded->[$i]{'expiry'}) . " - Time left in seconds: $SubsDecoded->[$i]{'timeleft'}\n");
};

print("
\n Exiting in 10 secs...
");
sleep(10);
exit(0);