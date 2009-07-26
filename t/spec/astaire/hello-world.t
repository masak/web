use v6;
use Test;

# L<Astaire/Astaire spec/Sometimes you just want to write a really small>

class TestApp is Astaire::Base {
    get '/' => {
        'Hello World'
    }
}

ok TestApp ~~ Callable;
ok TestApp.new.can('postfix:<()>');

my $request = Web::MockRequest.new(TestApp);
my $response = $request.get('/');
ok $response.is_ok;
is 'Hello World', $response.body;

done_testing;
