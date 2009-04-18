use HTTP::Daemon;
use Tags;

sub request($c) {
    my $r = $c.get_request();
    my $m = $r.req_method();
    if $m eq 'GET' {
        given $r.url.path {
            when '/'             { main_page( $c, $r ); }
            when m{^\/<digit>*$} { show_paste( $c, $r ); }
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
                h1 'Kopipasta is a PASTEBIN site for COPYING and/or PASTING';
                p { outs 'put some text in me'; strong 'I AM HUNGRY FOR TEXT'; }
                form :method<POST>, :action</paste>, {
                    p {
                        label :for<name>, 'Name: '; input :name<name>, :id<name>;
                    }
                    p {
                        label :for<title>, 'Title: '; input :name<title>, :id<title>;
                    }
                    p {
                        textarea :cols<80>, :rows<20>, :name<content>;
                    }
                    input :type<submit>, :name<paste>, :value('PASTE ME')
                }
            }
        }
    }
}

sub show_paste($c, $r) {
    my $match = $r.url.path ~~ m{^\/(<digit>+)$};
    my $id = $match[0];
    my %query = fetch_paste($id);
    my $name = %query<name> // "Someone";
    my $title = %query<title>;
    my $content = %query<content>;
    $c.send_response: show {
        html {
            head {
                title "kopipasta \"$title\" by $name"
            };
            body {
                h1 "$name pasted \"$title\" some time ago";
                $content ?? pre($content) !! p("wtf dood?!?!  No paste here!");
                a :href</>, 'make ur own paste, dood';
            }
        }
    }
}

sub paste($c, $r) {
    my $id = save_paste($r.query);

    $c.send_status_line(303, 'See Other');
    $c.send_headers(:Location("/$id"));
    $c.send_crlf;
    $c.close;
    # TODO Send a redirect instead of 200 OK
    $c.send_response: show {
        html {
            head {
                title 'kopipasta'
            };
            body {
                h1 'you pasted text!';
                p { outs 'you can find it '; a :href("/$id"), 'here'; }
            }
        }
    }
}

my %pastes;
sub fetch_paste($id) {
    # TODO go to filesystem
    %pastes{$id}
}

sub save_paste($q) { # TODO save username, title, time, etc
    # TODO avoid collisions
    my $id = int(rand*1000000);

    # TODO go to filesystem
    %pastes{$id} = $q;
    return $id;
}

sub daemon {
    my HTTP::Daemon $d .= new( :host('127.0.0.1'), :port(2080) );
    say "Browse this Perl 6 web server at {$d.url}";
    $d.daemon();
}

defined @*ARGS[0] && @*ARGS[0] eq '--request' ?? request() !! daemon();
