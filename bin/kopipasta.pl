use HTTP::Daemon;
use Tags;
use HTML::Entities;

my %pastes;

sub request($c) {
    my $r = $c.get_request();
    my $m = $r.req_method();
    given $r.url.path {
        when '/'             { main_page( $c, $r ); }
        when m{^\/paste$}    { paste( $c, $r ); }
        when m{^\/<digit>+$} { show_paste( $c, $r ); }
        when *               { $c.send_error('RC_NOTFOUND'); }
    }
}

sub main_page($c, $r) {
    $c.send_response: show {
        html {
            head {
                title { 'kopipasta' };
                style :type<text/css>, '#recent { float: right; list-style-type: none;}';
            };
            body {
                h1 'Kopipasta is a PASTEBIN site for COPYING and/or PASTING';
                if %pastes {
                    ul :id<recent>, {
                        p 'Recent pastes';
                        for %pastes.kv -> $k, $v {
                            li a :href("/$k"), $v<title>;
                        }
                    }
                }
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
    my $name = encode_entities(%query<name> // "Someone");
    my $title = encode_entities(%query<title>);
    my $content = %query<content>;
    $c.send_response: show {
        html {
            head {
                title "kopipasta \"$title\" by $name"
            };
            body {
                h1 "$name pasted \"$title\" some time ago";
                $content ?? pre(encode_entities($content)) !! p("wtf dood?!?!  No paste here!");
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
}

sub fetch_paste($id) {
    # TODO go to filesystem
    unless defined %pastes{$id} {
        %pastes{$id} = eval(open("/tmp/pastes/$id.paste").slurp);
    }
    return %pastes;
}

sub save_paste($q) { # TODO save time, etc
    # TODO avoid collisions
    my $id = int(rand*1000000);

    %pastes{$id} = $q;
    my $f = open("/tmp/pastes/$id.paste", :w);
    my $result = $f.say($q.perl);
    $f.close();
    $*ERR.say("IO error: $result") unless $result;
    return $id;
}

sub daemon {
    my HTTP::Daemon $d .= new( :host('0.0.0.0'), :port(2080) );
    say "Browse this Perl 6 web server at http://localhost:2080/";
    $d.daemon();
}

defined @*ARGS[0] && @*ARGS[0] eq '--request' ?? request() !! daemon();
