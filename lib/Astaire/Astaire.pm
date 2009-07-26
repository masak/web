#!/usr/bin/perl6
module Astaire {
    sub get( Pair $param ) is export {
        my ( $condition, $code ) = $param.kv;
        if $condition ~~ Str {
            
        } elsif $condition ~~ Regex {
            
        }
    }
}
