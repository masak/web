use HTTP::Daemon;
use Tags;

sub request($c) {
    my $r = $c.get_request();
    my $m = $r.req_method();
    if $m eq 'GET' {
        given $r.url.path {
            when '/'             { main_page( $c, $r ); }
            when * { $c.send_error('RC_FORBIDDEN'); }
        }
    }
    elsif $m eq 'POST' {
        paste($c, $r);
    }
    else {
        $c.send_error('RC_FORBIDDEN');
    }
}

sub main_page($c, $r) {
    $c.send_response: show {
        html {
            head {
                title { 'kopipasta' }
            };
            body {
                h1 { 'Kopipasta is a PASTEBIN site for COPYING and/or PASTING' }
                p { outs 'put some text in me'; strong { 'I AM HUNGRY FOR TEXT' } }
                form :method<POST>, :action</paste>, {
                    p {
                        textarea :cols<80>, :rows<20>, :name<content>, { '' }
                    }
                    input :type<submit>, :name<paste>, :value('PASTE ME'), { '' }
                }
            }
        }
    }
}

sub paste($c, $r) {
    $c.send_response: show {
        html {
            head {
                title { 'kopipasta' }
            };
            body {
                h1 { 'you pasted text' };
                pre {
                    $r.query<content>;
                }
            }
        }
    }
}

sub daemon {
    my HTTP::Daemon $d .= new( :host('127.0.0.1'), :port(2080) );
    say "Browse this Perl 6 web server at {$d.url}";
    $d.daemon();
}

defined @*ARGS[0] && @*ARGS[0] eq '--request' ?? request() !! daemon();
