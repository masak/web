use v6;

use Test;

plan 3;

use URI::Dispatcher;

{
    my $callback_called = False;

    my $d = URI::Dispatcher.new(
        '/' => { $callback_called = True }
    );

    ok $d.dispatch('/'), 'can dispatch on provided literal URL';
    ok $callback_called, 'the provided callback was called';

    nok $d.dispatch('/something/made/up'), 'failed dispatch';
}
