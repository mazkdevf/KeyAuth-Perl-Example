package KeyAuth;

require HTTP::Request;

use JSON::MaybeXS qw(encode_json);
use JSON;
use LWP::UserAgent;
use Time::Piece;
use Win32;

$Initialized = false;
my $sessionid = "Null Session";

my $name = "";
my $ownerid = "";
my $version = "1.0";

$AppInfo{'numUsers'} = "";
$AppInfo{'numOnlineUsers'} = "";
$AppInfo{'numKeys'} = "";
$AppInfo{'version'} = $version;
$AppInfo{'customerPanelLink'} = "";

$user_data{'username'} = "";
$user_data{'ip'} = "";
$user_data{'hwid'} = "";
$user_data{'createdate'} = "";
$user_data{'lastlogin'} = "";

%user_data_Subscriptions = ( );

sub Api {
    $appname = $_[0];
    $appownerid = $_[1];
    $appsecret = $_[2];
    $appversion = $_[3];

    print($appname, $appownerid, $appsecret, $appversion);

    if (!$appname || !$appownerid || !$appsecret || !$appversion) {
        print("\n Error: Application is not set up correctly.");
        exit(0);
    };

    $name = $appname;
    $ownerid = $appownerid;
    $version = $appversion;
}

sub Init {
    my $url = "https://keyauth.win/api/1.1/?type=init&name=${name}&ownerid=${ownerid}&ver=${version}";
    $response = Req($url);

    if ($response->decoded_content =~ "KeyAuth_Invalid") {
        print("Error: Application not found");
        exit(0);
    }

    my $json = decode_json($response->content);

    if ($json->{'success'}) {

        $Initialized = true;
        $sessionid = $json->{'sessionid'};
        Load_AppInfo(encode_json($json->{'appinfo'}));
    } elsif ($json->{'message'} == "invalidver") {
        print("Error: Invalid version");
        exit(0);
    } else {
        print("Error: " . $json->{'message'});
        exit(0);
    }
}

sub Upgrade {
    $Username = $_[0];
    $Key = $_[1];

    my $url = "https://keyauth.win/api/1.1/?type=upgrade&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&key=${Key}&username=${Username}";
    $response = Req($url);
    my $json = decode_json($response->content);

    if ($json->{'success'}) {
        print("Successfully upgraded!");
        exit(0);
    } else {
        print("Error: " . $json->{'message'});
        exit(0);
    }
}

sub Login {
    $Username = $_[0];
    $Password = $_[1];

    $hwid = GetHwid();

    my $url = "https://keyauth.win/api/1.1/?type=login&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&username=${Username}&pass=${Password}&hwid=${hwid}";
    $response = Req($url);
    my $json = decode_json($response->content);

    if ($json->{'success'}) {
        Load_UserData(encode_json($json->{'info'}));
    } else {
        print("\nError: " . $json->{'message'});
        exit(0);
    }
}

sub Register {
    $Username = $_[0];
    $Password = $_[1];
    $Key = $_[2];

    $hwid = GetHwid();

    my $url = "https://keyauth.win/api/1.1/?type=register&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&username=${Username}&pass=${Password}&key=${Key}&hwid=${hwid}";
    $response = Req($url);
    my $json = decode_json($response->content);

    if ($json->{'success'}) {
        Load_UserData(encode_json($json->{'info'}));
    } else {
        print("\nError: " . $json->{'message'});
        exit(0);
    }
}

sub License {
    $key = $_[0];

    $hwid = GetHwid();

    my $url = "https://keyauth.win/api/1.1/?type=license&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&key=${key}&hwid=${hwid}";
    $response = Req($url);
    my $json = decode_json($response->content);

    if ($json->{'success'}) {
        Load_UserData(encode_json($json->{'info'}));
    } else {
        print("\nError: " . $json->{'message'});
        exit(0);
    }
}

sub Var {
    $varid = $_[0];

    my $url = "https://keyauth.win/api/1.1/?type=var&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&varid=${varid}";
    $response = Req($url);
    my $json = decode_json($response->content);

    if ($json->{'success'}) {
        return $json->{'message'};
    } else {
        return "";
    }
}

sub Setvar {
    $varid = $_[0];
    $data = $_[1];

    my $url = "https://keyauth.win/api/1.1/?type=setvar&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&var=${varid}&data=${data}";
    $response = Req($url);
    my $json = decode_json($response->content);

    if ($json->{'success'}) {
        return true;
    } else {
        return false;
    }
}

sub Getvar {
    $varid = $_[0];

    my $url = "https://keyauth.win/api/1.1/?type=getvar&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&var=${varid}";
    $response = Req($url);
    my $json = decode_json($response->content);

    if ($json->{'success'}) {
        return $json->{'message'};
    } else {
        return "";
    }
}

sub Check {
    $hwid = GetHwid();

    my $url = "https://keyauth.win/api/1.1/?type=check&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&hwid=${hwid}";
    $response = Req($url);
    my $json = decode_json($response->content);

    if ($json->{'success'}) {
        return true;
    } else {
        return false;
    }
}

sub CheckBlacklist {
    $hwid = GetHwid();

    my $url = "https://keyauth.win/api/1.1/?type=check&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&hwid=${hwid}";
    $response = Req($url);
    my $json = decode_json($response->content);

    if ($json->{'success'}) {
        return true;
    } else {
        return false;
    }
}

sub Webhook {
    $webid = $_[0];
    $params = $_[1];

    my $url = "https://keyauth.win/api/1.1/?type=webhook&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&webid=${webid}&params=${params}";
    $response = Req($url);
    my $json = decode_json($response->content);

    if ($json->{'success'}) {
        return $json->{'message'};
    } else {
        return "";
    }
}

sub Log {
    $message = $_[0];
    $PcUser = Win32::LoginName || "UNKNOWN";
    $hwid = GetHwid();

    my $url = "https://keyauth.win/api/1.1/?type=log&name=${name}&ownerid=${ownerid}&sessionid=${sessionid}&hwid=${hwid}&pcuser=${PcUser}&message=${message}";
    $response = Req($url);
}

sub Load_UserData {
    $EncodedJson = $_[0];
    my $json = decode_json($EncodedJson);

    $user_data{'username'} = $json->{'username'};
    $user_data{'ip'} = $json->{'ip'};
    $user_data{'hwid'} = $json->{'hwid'};
    $user_data{'createdate'} = $json->{'createdate'};
    $user_data{'lastlogin'} = $json->{'lastlogin'};

    %user_data_Subscriptions = encode_json($json->{'subscriptions'});
}

sub Load_AppInfo {
    $EncodedJson = $_[0];
    my $json = decode_json($EncodedJson);

    $AppInfo{'numUsers'} = $json->{'numUsers'};
    $AppInfo{'numOnlineUsers'} = $json->{'numOnlineUsers'};
    $AppInfo{'numKeys'} = $json->{'numKeys'};
    $AppInfo{'version'} = $json->{'version'};
    $AppInfo{'customerPanelLink'} = $json->{'customerPanelLink'};
}

sub Req {
    $url = $_[0];
    my $header = ['Content-Type' => 'application/x-www-form-urlencoded'];
 
    my $r = HTTP::Request->new('POST', $url, $header);
    $ua = LWP::UserAgent->new;
    $response = $ua->request($r);
    return $response;
}

sub UnixToDate {
    $unix = $_[0];
    $time = localtime($unix)->strftime('%F %T');
    return $time;
}

sub GetHwid {
    $hwid = "PERL_EXAMPLE";
    return $hwid;
}

sub ClearConsole {
    system("cls");
}

return 1;