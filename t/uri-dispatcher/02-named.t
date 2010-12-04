use v6;

use Test;

plan 1;

use URI::Dispatcher;

{
    my $name;

    my $d = URI::Dispatcher.new(
        '/hello/:name' => { $name = .<name> }
    );

    ok $d.dispatch('/hello/world'), 'named parameters work';
}
