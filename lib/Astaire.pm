#!/usr/bin/perl6
use Web::Request;
use Web::Response;

class Handler {
    has Str $.condition;
    has Block $.code;
    has Str $.http_method;
};

class Dispatch {
    has @.handlers;

    method push ( Handler $handler ){
        @.handlers.push( $handler );
    }

    method dispatch ( Web::Request $request ){
        my Web::Response $response .= new();

        for @.handlers -> $candidate {
            if $candidate.condition eq $request.path_info and $candidate.http_method eq $request.request_method {
                my $code = $candidate.code;
                $response.write( $code() );
                return $response;
            }
        }
        
        #Not found
        $response.status = 404;
        return $response;
    }
};


#Rack compliant application
class AstaireApp {

    has Dispatch $.dispatch is rw;

    method call ( Web::Request $request ){
        return $.dispatch.dispatch( $request );
    }
};

module Astaire {

    my Dispatch $dispatch .= new();
    
    sub get( Pair $param ) is export {
        my ( $condition, $code ) = $param.kv;
        _push_to_dispatch( $condition, $code,'GET' );
    };

    sub post( Pair $param ) is export {
        my ( $condition, $code ) = $param.kv;
        _push_to_dispatch( $condition, $code,'POST' );
    };

    sub _push_to_dispatch ( $condition, $code, $http_method ){
        $dispatch.push( Handler.new( condition => $condition, code => $code, http_method => $http_method ) );
    }

    multi sub infix:<answers>(Str $condition, Code $code) is export { return ( $condition => $code ) }

    sub application () is export {
        my AstaireApp $application .= new( dispatch => $dispatch );
        return $application;
    }
};



      


