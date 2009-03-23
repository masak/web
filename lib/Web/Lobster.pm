class Web::Lobster {
    my $lobster-string = 'lobster';

    # RAKUDO: Should really be 'method postcircumfix:<( )>($env)' once this
    #         is supported.
    method call($env) {
        my Web::Request $req .= new($env);
        my Str ($lobster, $href);
        given $req.GET<flip> {
            when 'left' {
                $lobster = $lobster-string.split("\n").map(
                    { fmt('%-42s').reverse }
                ).join("\n");
                $href = '?flip=right';
            }
            when 'crash' {
                die "Lobster crashed";
            }
            default {
                $lobster = $lobster-string;
                $href = '?flip=left';
            }
        }
        
        my Web::Response $res .= new;
        $res.write($_) for
            '<title>Lobstericious!</title>',
            '<pre>',
            $lobster,
            '</pre>',
            "<p><a href='$href'>flip!</a></p>",
            "<p><a href='?flip=crash'>crash!</a></p>";
        $res.finish();
    }
}
