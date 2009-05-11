use LolDispatch;
use HTTP::Daemon;
use Tags;

my $posts-file = '/tmp/blog/posts.perl';
our @posts;
sub index($request, $match) is handler</> {
    show {
            html {
                head {
                    title { "blog index" }
                }
                body {
                    h1 'blog index';
                    ul {
                        for @posts.kv -> $k, $v {
                            li {
                                a :href("/post/$k"), $v<subject>;
                            }
                        }
                    }
                    a :href</post>, "new post";
                }
            }
        };
}

sub format-post($q) {
    return show {
            h2 $q<subject>;
            pre $q<body>;
        };
}

sub item($request, $match) is handler(/^\/post\/(\d+)/) {
    my $q = fetch-post($match[0]);
    show {
            html {
                head {
                    title $q<subject>;
                }
                body {
                    h1 { a :href</>, "omgblog" }
                    outs format-post($q);
                }
            }
        };
}

sub post($request, $match) is handler(/^\/post\/?$/) {
    show {
            html {
                head {
                    title 'make a new post';
                }
                body {
                    h1 'omg new post dood';
                    form :method<POST>, :action</submit>, {
                        p {
                            label :for<subject>, 'Subject: ';
                            input :name<subject>, :id<subject>;
                        }
                        p {
                            label :for<body>, 'Body: ';
                            textarea :cols<80>, :rows<20>, :name<body>, :id<body>;
                        }
                        input :type<submit>, :name<submit>, :value('POST BLOG');
                    }
                }
            }
        };
}

sub submit($request, $match) is handler(/^\/submit\/?$/) {
    my $id = save-post($request.query);
    show {
            p { outs 'Post number '; a :href("/post/$id"), { $id } };
        };
}

sub save-post($q) {
    my $id = @posts.elems;
    @posts[$id] = $q;
    my $fh = open($posts-file, :w);
    $fh.say( @posts.perl );
    $fh.close();
    return $id;
}

sub fetch-post($id) {
    @posts[$id];
}

sub request($c) {
    my $response := dispatch($c.get_request);
    $c.send_response: $response // "Error: no content";
}

@posts = $posts-file ~~ :f ?? eval(slurp($posts-file)).list !! ();

my HTTP::Daemon $d .= new( :host('0.0.0.0'), :port(2080) );
say "Check out http://localhost:2080/";
$d.daemon();
