use v6;

use Test;
plan 8;

use Routes;
given my $r = Routes.new {
    .add: ['foo', /'bar' | 'baz'/],   {  $^variant  };
    .add: ['foo', /^ \d+ $/],              { $^d };
    .add: [/^ \w+ $/],                     { "Yep!" if $^w.WHAT eq 'Match' };
    .add: ['foo', / \d+ /],                { $^d + 10 };
    .add: ['foo', / \d+ /, 'bar' ],        { $^d + 1 };
    .add: ['summ', / \d+ /, / \d+ / ],     { $^a + $^b };
    .add: ['bar', / $<w>=\w+ $<d>=\d+ / ], { my $m = $^a; $m<d> ~ $m<w> };
}

is $r.dispatch(<foo bar>), 
    'bar', 
    'Use regexp-rule to catch variant: bar';

is $r.dispatch(<foo baz>), 
    'baz', 
    'Use regexp-rule to catch variant: baz';
    
is $r.dispatch(['foo']), 
    'Yep!', 
    "Pattern with regex \w+, put Match in args";

is $r.dispatch(['foo', '50']), 
    '60', 
    "Dispatch ['foo', '50'] to last matched Route";

is $r.dispatch(['foo', 'a50z']), 
    '60', 
    'Pattern with regex \d, put Match in args';

is $r.dispatch(['foo', 'item4', 'bar']), 
    '5', 
    'Pattern with regexp in the middle (foo/\d+/bar)';

is $r.dispatch(['summ', '2', '3']), 
    '5', 
    'Pattern with two regexs';

is $r.dispatch(['bar', 'item2']), 
    '2item', 
    'Pattern with regexp, use abstract object in code';


# vim:ft=perl6
