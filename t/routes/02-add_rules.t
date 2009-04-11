use v6;

use Test;
plan 5;

use Routes;

my $r = Routes.new;

my @routes =  
    ['foo'],          { "A" },
    [/\d+/],          { "B" },
    ['foo', 'bar'],   { "C" },
    ['her' | 'boo'],  { "D" };

is($r.add(@routes), 4, "add list of routes, get the number added back");

is($r.dispatch(['foo']), "A", "Dispatch route ['foo']");
is($r.dispatch(['123']), "B", "Dispatch route /\\d+/");
is($r.dispatch(['foo', 'bar']), "C", "Dispatch route ['foo', 'bar']");
is($r.dispatch(['boo']), "D", "Dispatch route ['boo']");

# vim:ft=perl6
