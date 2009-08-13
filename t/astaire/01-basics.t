#!/usr/bin/perl6
use v6;
use Test;

plan 14;

#Basic test 
use Astaire;
ok(1, 'used Astaire without errors');

get '/hi' answers {
    "Hello World!"
};
ok(1, 'set up get action without errors');

post '/test' answers {
    2+2
};
ok(1, 'set up post action without errors');

my $astaire_app = application();
ok(1, 'set up application without errors');

{
    my Web::Request $req .= new({ PATH_INFO => "/hi", REQUEST_METHOD => "GET" });
    ok(1, 'set up request without errors');

    my Web::Response $response = $astaire_app.call( $req );
    ok(1, 'got response without errors');

    ok( $response.body eq "Hello World!" , 'body of response to get was as excpected');
    ok( $response.status == 200 , 'status of response to get was as excpected');

}

{
    my Web::Request $req .= new({ PATH_INFO => "/test", REQUEST_METHOD => "POST" });
    my Web::Response $response = $astaire_app.call( $req );
    ok( $response.body == 4 , 'response to post was as excpected');
}

{
    my Web::Request $req .= new({ PATH_INFO => "/doez_not_existz", REQUEST_METHOD => "GET" });
    my Web::Response $response = $astaire_app.call( $req );
    ok( $response.status == 404 , 'nonexistant page gives 404 error');
}

{
    my Web::Request $req .= new({ PATH_INFO => "/hi", REQUEST_METHOD => "POST" });
    my Web::Response $response = $astaire_app.call( $req );
    ok( $response.status == 404 , 'request to get action with post fails as excpected');
}

{
    my Web::Request $req .= new({ PATH_INFO => "/test", REQUEST_METHOD => "GET" });
    my Web::Response $response = $astaire_app.call( $req );
    ok( $response.status == 404 , 'request to post action with get fails as excpected');
}

get '/second_test' answers {
    "ho!"
};

{
    my Web::Request $req .= new({ PATH_INFO => "/second_test", REQUEST_METHOD => "GET" });
    my Web::Response $response = $astaire_app.call( $req );
    ok( $response.body eq 'ho!' , 'can add actions after application object was created');
}

get '/hi' answers {
    "This is a second action matching '/hi', it should never be called";
};

{
    my Web::Request $req .= new({ PATH_INFO => "/hi", REQUEST_METHOD => "GET" });
    my Web::Response $response = $astaire_app.call( $req );
    ok( $response.body eq "Hello World!" , 'double action matching same request works as excpected');
}
