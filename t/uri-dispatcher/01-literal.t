use v6;

use Test;

use URI::Dispatcher;

{
    my $d = URI::Dispatcher.new(
        '/' => {}
    );

    ok $d.dispatch('/'), 'can dispatch on provided literal URL';
}
