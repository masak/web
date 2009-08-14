#!/usr/bin/perl6
use Web::Request;
use Web::Response;

class Handler {
    has Str $.condition;
    has Block $.code;
    has Str $.http_method;

    method matches( $path ){
        my %result;
        my $clean_path = $path.subst( / ^\/ /, '', :g );
        my $condition = $.condition.subst( / ^\/ /, '', :g ).subst( / \. /, '\.', :g ).subst( / \/ /, '\/', :g ).subst( / \* /, '(.*)', :g );
        $condition = "/^ $condition \$/";
        #"$condition against $clean_path".say;
        # RAKUDO : There must be a nicer way to do this ( eg. no eval ) once we have regex interpolation stuff
        # RAKUDO : submethod BUILD doesn't work ( forgets its args ), we should eval the regex only on BUILD and then store it
        my $condition_regex = (eval " $condition ");
        my $match = $clean_path.match($condition_regex);
        my @splat = @($match).map({ ~$_ });
        %result{'splat'} = @splat;
        if $match {
            %result{'success'} = 1;
            return %result;   
        }else{
            %result{'success'} = 0;
            return %result;   
        }
    }

    method explode( Str $target ){
        my @path = $target.split('/');
        @path.shift() if @path[0] eq '';
        return @path
    }

};

class Dispatch {
    has @.handlers;

    method push ( Handler $handler ){
        @.handlers.push( $handler );
    }

    method dispatch ( Web::Request $request ){
        my Web::Response $response .= new();

        for @.handlers -> $candidate {
            my %match = $candidate.matches( $request.path_info );
            if %match{'success'} and $candidate.http_method eq $request.request_method {
                %match{'splat'}.perl.say;
                my $code = $candidate.code;
                $response.write( $code(|%match) );
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



      


