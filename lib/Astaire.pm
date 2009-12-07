use v6;

use Web::Request;
use Web::Response;

class Handler {
    has Str   $.condition;
    has Regex $!condition_regex;
    has Block $.code;
    has Str   $.http_method;

    submethod BUILD(:$!condition, :$!code, :$!http_method) {
        my $condition
            = $.condition.subst(/ ^\/ /, '',     :g )\
                         .subst(/ \. /,  '\.',   :g )\
                         .subst(/ \/ /,  '\/',   :g )\
                         .subst(/ \* /,  '(.*)', :g );
        $condition = "/^ $condition \$/";
        # RAKUDO: Doing eval here until we get variable interpolation in
        #         regexes.
        $!condition_regex = eval $condition;
    }

    method matches($path) {
        my %result;
        my $clean_path = $path.subst(/ ^\/ /, '');
        $clean_path ~~ $!condition_regex;
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
                $response.write( $code(|%match<splat>) );
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
