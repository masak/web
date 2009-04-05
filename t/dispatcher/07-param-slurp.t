use v6;

use Test;
plan 3;

use Dispatcher;
my $d = Dispatcher.new;

$d.add: [
    ['foo', *], :slurp, { @_.join: '/' },
];

is( $d.dispatch(['foo', 1]), 
    'foo/1', 
    'Whatever with slurp take 1 args'  
);

is( $d.dispatch(['foo', 1, 2]), 
    'foo/1/2', 
    'Whatever with slurp take 2 args'  
);

is( $d.dispatch(['foo', 1, 2, 3]), 
    'foo/1/2/3', 
    'Whatever with slurp take 3 args'  
);


# vim:ft=perl6
