# A more or less direct port of
# <http://github.com/chneukirchen/rack/blob/master/lib/rack/lobster.rb>
# This file is distributed under the license found in licenses/rack/COPYING.

use v6;

use Web::Request;
use Web::Response;

class Web::Nibbler does Callable {
    # Somewhat less cool than the Ruby solution, we have to include the
    # lobster verbatim, for lack of a zlib module (hint, hint).
    my $nibbler-string = q[
              +   ?:
             .    M..
                    7
              ...  $
                 MMO
                 8MM.
                 ~MM.
                  MM.
                +MMMM~.
              MMMMMMMMMO
          =MMMMMMMMMMMMMMMMM..
     . .MMMMMMMMMMMMMMMMMMMMM7MMMMMM  .
   MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM?
=MMMMMMMMMMMMMMMMMMMMMMMMMMN..     M,
  $       :MMMMMMMMMMMMMMMM           .
  .      MM MMMMMMMMMMMMMM.       MMM.,.
I      ..Z? ~MMMMMMMMMMMMM        ...
:           .MMMMMMMMMMMMM            =
N .        .NMMMMM88DMMMMMM.       .
Z         =MM,,:MMMMMI,:MMM     . .D.
  ,.     .MMMMM::$MMMM::~$MMMMMDDMD.
  ..MMMMMD:,,,,,:,:,,:,,:,,,:::MMM
    .MM,,,,,,,,,,,,,,,,,,,,,,,,:,,$ .
     =:,,::::,,:?$O88OZZZZON88O$Z8?
     .M::,,:N .I,,,,,,,,,,,,.  ,.
     . .Z+,::.+::,,,,,,,,,,:M M
        . ..I~::,:,,,,,,,,8..];

    method postcircumfix:<( )>($env) {
        my Web::Request $req .= new($env);
        my Str ($nibbler, $href);
        given $req.GET<flip> // '' {
            when 'left' {
                $nibbler = $nibbler-string.split("\n").map(
                    { .fmt('%-42s').flip }
                ).join("\n");
                $href = '?flip=right';
            }
            when 'crash' {
                die "Nibbler crashed";
            }
            default {
                $nibbler = $nibbler-string;
                $href = '?flip=left';
            }
        }
        
        my Web::Response $res .= new;
        $res.write($_) for
            '<title>Look! A Nibblonian!</title>',
            '<pre>',
            $nibbler,
            '</pre>',
            "<p><a href='$href'>flip!</a></p>",
            "<p><a href='?flip=crash'>crash!</a></p>";
        $res.finish();
    }
}
