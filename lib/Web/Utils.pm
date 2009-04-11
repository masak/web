use v6;
# A more or less direct port of
# <http://github.com/chneukirchen/rack/blob/master/lib/rack/utils.rb>
# This file is distributed under the license found in licenses/rack/COPYING.

module Web::Utils {
    # Web::Utils contains a grab-bag of useful methods for writing web
    # applications adopted (through Rack) from all kinds of Ruby libraries.

    # Performs URI escaping so that you can construct proper
    # query strings faster.
    sub escape($s) is export {
        # RAKUDO: Need 'H2' in Rakudo's unpack before this works
        # RAKUDO: Also need to turn the string into bytes before letting
        #         the substitution loose on it.
        return (~$s).subst(/<-[ a..zA..Z0..9_.\-]>+/,
            { '%' ~ unpack(~$/, "H2" x $/.chars).join('%').uc },
            :global).trans(' ' => '+');
    }

    # Unescapes a URI escaped string.
    sub unescape(Str $s) is export {
        return $s.trans('+' => ' ').subst(/['%'<[0..9a..fA..F]>**2]+/,
            { $/.subst('%', '', :global).pack('H*') },
            :global);
    }

    # Parses a query string by breaking it up at the '&'
    # and ';' characters.  You can also use this to parse
    # cookies by changing the characters used in the second
    # parameter (which defaults to '&;').
    sub parse_query(Str $qs, $d = '&;') {
        my %params = {};

        # RAKUDO: Need to solve this with eval right now. [perl #63892]
        my $regex = eval("/<[$d]>/");
        for ($qs // '').split($regex) -> $p {
            my ($k, $v) = unescape($p).split('=', 2);

            (%params{$k} //= []).push($v);
        }

        for %params.kv -> $k, $v {
            %params{$k} = $v[0] if $v.elems == 1;
        }

        return %params;
    }

    sub parse_nested_query(Str $qs, $d = '&;') {
        my %params = {};

        # RAKUDO: Need to solve this with eval right now. [perl #63892]
        my $regex = eval("/<[$d]>/");
        for ($qs // '').split($regex) -> $p {
            my ($k, $v) = unescape($p).split('=', 2);

            normalize_params(%params, $k, $v);
        }
        return %params;
    }

    sub normalize_params(%params is rw, $name, $v = undef) {
        $name ~~ / <[ \[ \] ]>* (<-[ \[ \] ]>+) \]* /;
        my $k = ~$0;
        my $after = $name.substr($/.to);

        return unless $k.chars;

        given $after {
            when '' {
                %params{$k} = $v;
            }
            when '[]' {
                %params{$k} //= [];
                die 'Type error' unless %params{$k} ~~ List;
                %params{$k}.push($v);
            }
            when /^ '[][' (<-[ \[ \] ]>+) ']' $/ | /^ '[]'(.+) $/ {
                my $child_key = ~$0;
                %params{$k} //= [];
                die 'Type error' unless %params{$k} ~~ List;
                if %params{$k}[*-1] ~~ Hash
                   && !%params{$k}[*-1].exists($child_key) {
                    normalize_params(%params{$k}[*-1], $child_key, $v);
                }
                else {
                    %params{$k}.push(
                        normalize_params(%params{$k}, $after, $v)
                    );
                }
            }
            default {
                %params{$k} //= {};
                %params{$k} = normalize_params(%params{$k}, $after, $v);
            }
        }

        return %params;
    }

    sub build-query(Hash %params) is export {
        return %params.pairs.map({
            my ($k, $v) = .kv;
            $v ~~ List ??  build-query($v.map: { [$k, $^x] })
                       !!  escape($k) ~ '=' ~ escape($v)
        }).join('&');
    }

    # Escape ampersands, brackets and quotes to their HTML/XML entities.
    sub escape-html($string) {
        return (~$string).subst('&', '&amp;' )\
                         .subst('<', '&lt;'  )\
                         .subst('>', '&gt;'  )\
                         .subst(q['],'&#39;' )\
                         .subst('"', '&quot;');
    }

    sub select-best-encoding($available-encodings, $accept-encoding) {
        # http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html

        # XXX: This became too complicated for me without further knowledge.
        #      Punting for now.
    }

    # The recommended manner in which to implement a contexting application
    # is to define a method #context in which a new Context is instantiated.
    #
    # As a Context is a glorified block, it is highly recommended that you
    # define the contextual block within the application's operational scope.
    class Context is Routine {
        # TODO
    }

    # A case-insensitive Hash that preserves the original case of a
    # header when set.
    class HeaderHash is Hash {
        # TODO
    }

    # Every standard HTTP code mapped to the appropriate message.
    # Stolen from Mongrel.
    my %HTTP_STATUS_CODES =
      100  => 'Continue',
      101  => 'Switching Protocols',
      200  => 'OK',
      201  => 'Created',
      202  => 'Accepted',
      203  => 'Non-Authoritative Information',
      204  => 'No Content',
      205  => 'Reset Content',
      206  => 'Partial Content',
      300  => 'Multiple Choices',
      301  => 'Moved Permanently',
      302  => 'Found',
      303  => 'See Other',
      304  => 'Not Modified',
      305  => 'Use Proxy',
      307  => 'Temporary Redirect',
      400  => 'Bad Request',
      401  => 'Unauthorized',
      402  => 'Payment Required',
      403  => 'Forbidden',
      404  => 'Not Found',
      405  => 'Method Not Allowed',
      406  => 'Not Acceptable',
      407  => 'Proxy Authentication Required',
      408  => 'Request Timeout',
      409  => 'Conflict',
      410  => 'Gone',
      411  => 'Length Required',
      412  => 'Precondition Failed',
      413  => 'Request Entity Too Large',
      414  => 'Request-URI Too Large',
      415  => 'Unsupported Media Type',
      416  => 'Requested Range Not Satisfiable',
      417  => 'Expectation Failed',
      500  => 'Internal Server Error',
      501  => 'Not Implemented',
      502  => 'Bad Gateway',
      503  => 'Service Unavailable',
      504  => 'Gateway Timeout',
      505  => 'HTTP Version Not Supported'
    ;

    # Responses with HTTP status codes that should not have an entity body
    my %STATUS_WITH_NO_ENTITY_BODY;
    # RAKUDO: map within module declaration doesn't work.
    for 100..199, 204, 304 {
        %STATUS_WITH_NO_ENTITY_BODY{$_} = 1;
    }

    # A multipart form data parser, adapted from IOWA.
    #
    # Usually, Web::Request.POST takes care of calling this.

    module Multipart {
        # TODO
    }
}
