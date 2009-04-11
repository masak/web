use v6;
use Test;
plan 5;

use Routes;

my $r = Routes.new( default => { "default" } );

$r.add: [
    [*,],                 {  $^a  },
    [*,*],                {  $^a + $^b },
    ['foo', *],           { 'foo/' ~ $^a },
    ['foo', *, *],        { 'foo:' ~ $^a - $^b },
    ['foo', *, 'bar'],    { $^b },
];

is( $r.dispatch([42]), 42, 'Pattern *' );
is( $r.dispatch([1, 2]), 3, 'Pattern */* ' );
is( $r.dispatch(['foo', '5']), "foo/5", 'Pattern foo/*' );
is( $r.dispatch(['foo', '5', 1]), "foo:4", 'Pattern foo/*/*' );
is( $r.dispatch(['foo', 'baz', 'bar']), "baz", 'Pattern foo/*/bar' );


# vim:ft=perl6
