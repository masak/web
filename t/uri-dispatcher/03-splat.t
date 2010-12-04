use v6;

use Test;

plan 2;

use URI::Dispatcher;

{
    my $name;

    my $d = URI::Dispatcher.new(
        '/hello/*' => { $name = .<splat>[0] // 'not set' }
    );

    ok $d.dispatch('/hello/world'), 'splat works';
    is $name, 'world', '...and it saves the parameter';
}
