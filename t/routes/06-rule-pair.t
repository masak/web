use v6;

use Test;
plan 4;

use Routes;
my $r = Routes.new;

$r.add: [ 
    [:controller, :action ],    { 'c:' ~ $:controller ~ ' a:' ~ $:action },
    [:controller, / \d / ],     {  $:controller ~ '/' ~ $^a },
    [:controller, *, * ],       { my $c = $:controller; use "$c"; is($^a, $^b, 'Test within Route code block') };
];

is( $r.dispatch(['one', 5]), 
    'one/5', 
    'Pattern set controller'  
);

is( $r.dispatch(['one', 'two']), 
    'c:one a:two', 
    'Pair rule set controller and action'  
);

is( $r.dispatch(['Test', 3, 3]), 
    1, 
    'Pair rule set controller and action'  
);

# vim:ft=perl6
