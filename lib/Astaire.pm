use v6;

use Web::Request;
use Web::Response;

class Handler {
    has Str   $.condition;
    has Regex $!condition-regex;
    has Block $.code;
    has Str   $.http_method;

    sub remove-initial-slash($s) {
        # RAKUDO: prefix:<~> needed because of [perl #71088]
        ~$s.subst(rx[ ^ '/' ], '');
    }

    submethod BUILD(:$!condition, :$!code, :$!http_method) {
        my $condition
            = remove-initial-slash($.condition)\
              .trans(    [<  .  /   *  >]
                      => [< \. \/ (.*) >] );
        $condition = "/^ $condition \$/";
        # RAKUDO: Doing eval here until we get variable interpolation in
        #         regexes.
        $!condition-regex = eval $condition;
    }

    method matches($path) {
        my %result;
        my $clean-path = remove-initial-slash($path);
        $clean-path ~~ $!condition-regex;
        %result<splat> = @($/).map({ ~$_ });
        %result<success> = ?$/;
        return %result;
    }
}

class Dispatch {
    has Handler @.handlers handles <push>;

    method dispatch(Web::Request $request) {
        my Web::Response $response .= new();

        for @.handlers -> $candidate {
            my %match = $candidate.matches( $request.path_info );
            if %match<success>
               && $candidate.http_method eq $request.request_method {
                my $code = $candidate.code;
                my $body;
                if $code.signature.params == 1
                   && $code.signature.params[0].name eq '@splat' {
                    $body = $code(:splat(%match<splat>));
                }
                elsif $code.arity {
                    $body = $code(|%match<splat>);
                }
                else {
                    $body = $code();
                }
                $response.write($body);
                return $response;
            }
        }
        
        # Not found
        $response.status = 404;
        return $response;
    }
}

# Rack-compliant application
class AstaireApp {
    has Dispatch $.dispatch is rw;

    method call(Web::Request $request) {
        return $.dispatch.dispatch($request);
    }
}

module Astaire {
    my Dispatch $dispatch .= new();
    
    sub get(Pair $param) is export {
        my ($condition, $code) = $param.kv;
        _push_to_dispatch( $condition, $code,'GET' );
    };

    sub post(Pair $param) is export {
        my ($condition, $code) = $param.kv;
        _push_to_dispatch( $condition, $code,'POST' );
    };

    sub _push_to_dispatch ($condition, $code, $http_method) {
        $dispatch.push( Handler.new(:$condition, :$code, :$http_method) );
    }

    sub application () is export {
        my AstaireApp $application .= new(:$dispatch);
        return $application;
    }
}
