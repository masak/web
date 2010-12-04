use v6;

use Test;

plan 5;

use URI::Dispatcher;

{
    my $name;

    my $d = URI::Dispatcher.new(
        '/hello/:name' => { $name = .<name> // 'not set' }
    );

    ok $d.dispatch('/hello/world'), 'named parameters work';
    is $name, 'world', 'the name was captured properly';
}

{
    my $phrase;
    my $target;

    my $d = URI::Dispatcher.new(
        '/say/:phrase/to/:target' => {
            $phrase = .<phrase> // 'not set';
            $target = .<target> // 'not set';
        }
    );

    ok $d.dispatch('/say/hello/to/world'), 'several named captures';
    is $phrase, 'hello', 'first capture';
    is $target, 'world', 'second capture';
}
