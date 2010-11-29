use v6;
use Test;

use Astaire;

plan 4;

# L<Astaire/Astaire spec/Sometimes you just want to write a really small>

skip(4, 'Astaire::Base not implemented yet');
##class TestApp is Astaire::Base {
##    get '/' => {
##        'Hello World'
##    }
##}
##
##ok TestApp ~~ Callable;
##ok TestApp.new.can('postcircumfix:<()>');
##
##my $request = Web::MockRequest.new(TestApp);
##my $response = $request.get('/');
##ok $response.is_ok;
##is 'Hello World', $response.body;
