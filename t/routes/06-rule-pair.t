use v6;

use Test;
plan 4;

use Routes;
given my $r = Routes.new {
    .add: [:controller, :action ],    { 'c:' ~ $:controller ~ ' a:' ~ $:action };
    .add: [:controller, / \d / ],     {  $:controller ~ '/' ~ $^a };
    .add: [:controller, *, * ],       { 
        my $c = $:controller; 
        use "$c"; 
        is $^a, $^b, 'Test within Route code block' 
    };
}

is $r.dispatch(['one', 5]), 
    'one/5', 
    'Pattern set controller';

is $r.dispatch(['one', 'two']), 
    'c:one a:two', 
    'Pair rule set controller and action';

is $r.dispatch(['Test', 3, 3]), 
    1, 
    'Pair set controller -- Test, code use args to make next test';

# vim:ft=perl6
