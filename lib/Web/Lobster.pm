# A more or less direct port of
# <http://github.com/chneukirchen/rack/blob/master/lib/rack/lobster.rb>
# This file is distributed under the license found in licenses/rack/COPYING.

use v6;

use Web::Request;
use Web::Response;

class Web::Lobster {
    # Somewhat less cool than the Ruby solution, we have to include the
    # lobster verbatim, for lack of a zlib module (hint, hint).
    my $lobster-string = q[
                             ,.---._
                   ,,,,     /       `,
                    \\\\   /    '\_  ;
                     |||| /\/``-.__\;'
                     ::::/\/_
     {{`-.__.-'(`(^^(^^^(^ 9 `.========='
    {{{{{{ { ( ( (  (   (-----:=
     {{.-'~~'-.(,(,,(,,,(__6_.'=========.
                     ::::\/\
                     |||| \/\  ,-'/,
                    ////   \ `` _/ ;
                   ''''     \  `  .'
                             `---];

    # RAKUDO: Should really be 'method postcircumfix:<( )>($env)' once this
    #         is supported.
    method call($env) {
        my Web::Request $req .= new($env);
        my Str ($lobster, $href);
        given $req.GET<flip> // '' {
            when 'left' {
                $lobster = $lobster-string.split("\n").map(
                    { .fmt('%-42s').flip }
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
