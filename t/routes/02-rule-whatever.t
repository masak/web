use v6;
use Test;
plan 9;

use Routes;

given my $r = Routes.new: default => { 'default' }  {
    .add: [*,],              {  $^a  }; # [@ *] or [list *] works too, but not [*]
    .add: [*,*],             {  $^a + $^b };
    .add: ['foo', *],        { 'foo/' ~ $^a };
    .add: ['foo', *, *],     { 'foo:' ~ $^a - $^b };
    .add: ['foo', *, 'bar'], { $^b };
    .add: ['bar', *], :slurp, {  
        # RAKUDO: lose first arg in @_ [perl #63974]
        @_.unshift: $^a; 
        @_.join: '/';
    };
}

is $r.dispatch([42]), 
    42, 
    'Pattern *';

is $r.dispatch([1, 2]), 
    3, 
    'Pattern */* ';

is $r.dispatch(['foo', '5']), 
    'foo/5', 
    'Pattern foo/*';

is $r.dispatch(['foo', '5', 1]), 
    "foo:4", 
    'Pattern foo/*/*';

is $r.dispatch(['foo', 'baz', 'bar']), 
    'baz', 
    'Pattern foo/*/bar';

is $r.dispatch(['bar', 1]), 
    '1', 
    'Whatever with slurp take any number of args, 1 args';

is $r.dispatch(['bar', 1, 2]), 
    '1/2', 
    'Whatever with slurp take any numebr of args, 2 args';

is $r.dispatch(['bar', 1, 2, 3]), 
    '1/2/3', 
    'Whatever with slurp take any numebr of args, 3 args';

is $r.dispatch(['bar', 1, 'a', 3, 'b']), 
    '1/a/3/b', 
    'Whatever with slurp take any numebr of args, 4 args';

# vim:ft=perl6
