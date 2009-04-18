use HTTP::Daemon;
use Tags;

defined @*ARGS[0] && @*ARGS[0] eq '--request' ?? request() !! daemon();

sub request($c) {
    my $r = $c.get_request();
    if $r.req_method eq 'GET' {
        given $r.url.path {
            when '/'             { root_dir( $c, $r ); }
            when / ^ \/pub\/ $ / { pub_dir(  $c, $r ); }
        }
    }
    else {
        $c.send_error('RC_FORBIDDEN');
    }
}

sub root_dir($c, $r) {
    $c.send_response: show {
        html {
            head {
                title { "hi dood" }
            };
            body {
                h1 { 'wtf dood?!?!?!' }
                a :href</pub/>, { 'some stuff' }
            }
        }
    }
}

sub pub_dir($c, $r) {
    $c.send_response: show {
        html {
            head {
                title { "public filezzzzzzzz" }
            };
            body {
                p { 'hi dood' }
                a :href</>, { 'main page' }
            }
        }
    }
}

sub daemon {
    my HTTP::Daemon $d .= new( :host('127.0.0.1'), :port(2080) );
    say "Browse this Perl 6 web server at {$d.url}";
    $d.daemon();
}
