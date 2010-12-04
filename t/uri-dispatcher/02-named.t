use v6;

use Test;

plan 2;

use URI::Dispatcher;

{
    my $name;

    my $d = URI::Dispatcher.new(
        '/hello/:name' => { $name = .<name> // 'not set' }
    );

    ok $d.dispatch('/hello/world'), 'named parameters work';
    is $name, 'world', 'the name was captured properly';
}
