use v6;

use Test;
plan 3;

use Routes;

given my $r = Routes.new {
    .add: [:action(*)], :slurp, { $:action.join: '/' };
    .add: ['foo', *],   :slurp, { 
        # RAKUDO: lose first arg in @_ [perl #63974]
        @_.unshift: $^a; 
        @_.join: '/';
    };
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
    ':param(*) with slurp, put all args in this param'  
);

# vim:ft=perl6
