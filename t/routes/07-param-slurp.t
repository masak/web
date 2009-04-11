use v6;

use Test;
plan 3;

use Routes;
my $r = Routes.new;

for $r {
    .add: [:action(*)], :slurp, { $:action.join: '/' };
    .add: ['foo', *],   :slurp, { @_.join: '/' };
}

is( $r.dispatch(['foo', 1]), 
    '1', 
    'Whatever with slurp take 1 args'  
);

is( $r.dispatch(['foo', 1, 2]), 
    '1/2', 
    'Whatever with slurp take 2 args'  
);

is( $r.dispatch(['foo', 1, 2, 3]), 
    '1/2/3', 
    'Whatever with slurp take 3 args'  
);

is( $r.dispatch: ['bar', 'baz' ],
    'bar/baz',
    'Whatever as pair value put all args in param'  
);

# vim:ft=perl6
