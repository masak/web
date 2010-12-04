use v6;

use Test;

plan 5;

use URI::Dispatcher;

{
    my $name;

    my $d = URI::Dispatcher.new(
        '/hello/*' => { $name = .<splat>[0] // 'not set' }
    );

    ok $d.dispatch('/hello/world'), 'splat works';
    is $name, 'world', '...and it saves the parameter';
}

{
    my $path;
    my $extension;

    my $d = URI::Dispatcher.new(
        '/download/**.*' => {
            $path      = .<splat>[0] // 'not set';
            $extension = .<splat>[1] // 'not set';
        }
    );

    ok $d.dispatch('/download/path/to/file.xml'), 'multisplat works';
    is $path, 'path/to/file', '...and saves the first parameter';
    is $extension, 'xml', '...and the second';
}
