use v6;

use Test;
plan 4;

use Routes;
given my $r = Routes.new {
    .add: ['foo'|'bar'],    { 'First' };
    .add: ['foo', 'a'|'b'], { 'Second' };
}

is $r.dispatch(['foo']), 
    'First', 
    'Pattern with Junction (foo|bar) foo';

is $r.dispatch(['bar']), 
    'First', 
    'Pattern with Junction (foo|bar) bar';

is $r.dispatch(['foo', 'a']), 
    'Second', 
    'Pattern with Junction (foo/a|b) foo/a';

is $r.dispatch(['foo', 'b']), 
    'Second', 
    'Pattern with Junction (foo/a|b) foo/b';

# vim:ft=perl6
