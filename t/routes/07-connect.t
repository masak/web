use v6;

use Test;
plan 1;

class C::Root {
    method action { 'action: ' ~ $^foo }
    method index { 'index' }
}


use Routes;
given my $r = Routes.new( controllers => {Root => C::Root.new} ) {
    .connect: ['foo', :action, *];
}

is $r.dispatch(['foo', 'action', 3]), 
    'action: 3', 
    'Connect call action on the default (Root) controller';

# vim:ft=perl6
