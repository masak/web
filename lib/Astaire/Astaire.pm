#!/usr/bin/perl6

class Handler {

    has $.condition;
    has $.code;
    has $.http_method;

};

class Dispatch {

    has @.handlers;

    method push ( Handler $handler ){
        @.handlers.push( $handler );
    }
    
};

class Environnement{

};

#Rack compliant application
class AstaireApp {

    has $.dispatch;

    method call ( Environnement $environnement ){
        #return( $status, $headers, $body );
    }
    
};

module Astaire {

    my $dispatch = Dispatch.new();
    
    sub get( Pair $param ) is export {
        my ( $condition, $code ) = $param.kv;
        _push_to_dispatch( $condition, $code,'get' );
    };

    sub post( Pair $param ) is export {
        my ( $condition, $code ) = $param.kv;
        _push_to_dispatch( $condition, $code,'post' );
    };

    sub _push_to_dispatch ( $condition, $code, $http_method ){
        $dispatch.push( Handler.new( :condition<$condition>, :code<$code>, :http_method<$http_method> ) );
    }

    sub application () is export {
        $dispatch.handlers.perl.say;
        
        return AstaireApp.new( :dispatch<$dispatch> );
    }
};



      


