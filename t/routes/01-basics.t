use v6;

use Test;
plan 8;

use Routes;
ok(1,'We use Routes and we are still alive');

use Routes::Route;
ok(1,'We use Routes::Route and we are still alive');

my $r = Routes.new;

dies_ok( { $r.add: Routes::Route.new }, 
         '.add adds only complete Route objects' );

$r.add: Routes::Route.new( :pattern(''), code => { "Krevedko" } );

is( $r.dispatch(['']), 
    'Krevedko', 
    "Pattern ['']"
);

ok( $r.add( ['foo', 'bar'], { "Yay" } ), 
           '.add(@pattern, $code) -- shortcut for fast add Route object' );

nok( $r.dispatch(['foo']), 
    'Routes return False if can`t find matched Route and do not have default' );


is( $r.dispatch(['foo', 'bar']), 
    "Yay", 
    "Dispatch to Route ['foo', 'bar'])"
);

$r.default = { "Woow" };

is( $r.dispatch(['foo', 'bar', 'baz']), 
    "Woow", 
    'Dispatch to default, when have no matched Route'  
);

# vim:ft=perl6
