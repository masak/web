use v6;

use Test;
plan 5;

use Routes;

given my $r = Routes.new {
    .add: ['foo', *],   :slurp, { 
        # RAKUDO: lose first arg in @_ [perl #63974]
        @_.unshift: $^a; 
        @_.join: '/';
    };
    .add: ['bar', :action(*)], :slurp, { $:action.join: '/' };
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

is( $r.dispatch(['foo', 1, 2, 3, 4]), 
    '1/2/3/4', 
    'Whatever with slurp take 4 args'  
);

is( $r.dispatch(['bar', 1,2,3 ]),
    '1/2/3',
    ':param(*) with slurp, put all args in this param'  
);

# vim:ft=perl6
