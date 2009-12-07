#!/usr/bin/perl6
use v6;
use Test;

plan 18;

#Basic test 
use Astaire;
ok(1, 'used Astaire without errors');

get '/hi' => {
    "Hello World!"
};
ok(1, 'set up get action without errors');

post '/test' => {
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
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "/test", REQUEST_METHOD => "POST" }) );
    ok( $response.body == 4 , 'response to post was as excpected');
}

{
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "/doez_not_existz", REQUEST_METHOD => "GET" }) );
    ok( $response.status == 404 , 'nonexistant page gives 404 error');
}

{
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "/hi", REQUEST_METHOD => "POST" }) );
    ok( $response.status == 404 , 'request to get action with post fails as excpected');
}

{
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "/test", REQUEST_METHOD => "GET" }) );
    ok( $response.status == 404 , 'request to post action with get fails as excpected');
}

get '/second_test' => {
    "ho!"
};

{
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "/second_test", REQUEST_METHOD => "GET" }) );
    ok( $response.body eq 'ho!' , 'can add actions after application object was created');
}

get '/hi' => {
    "This is a second action matching '/hi', it should never be called";
};

{
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "/hi", REQUEST_METHOD => "GET" }) );
    ok( $response.body eq "Hello World!" , 'double action matching same request works as excpected');
}

get '/this/is/a/long/path' => {
    "Long path test";
};

{
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "this/is/a/long/path", REQUEST_METHOD => "GET" }) );
    ok( $response.body eq "Long path test" , 'matched on long ( > 1 ) path');
}

{ 

    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "this/is/a/very/long/path", REQUEST_METHOD => "GET" }) );
    ok(  $response.status == 404, '404 error with wrong long path ( different length )');
}

{ 
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "this/is/a/wrong/path", REQUEST_METHOD => "GET" }) );
    ok(  $response.status == 404, '404 error with wrong long path ( same length )');
}

get '/with/*/star' => {
    "Star";
};

{
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "with/anything/star", REQUEST_METHOD => "GET" }) );
    ok( $response.body eq "Star" , 'path with wildcard');
}

get '/path/to/file/*.*' => {
    "Starz";
};

{
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "/path/to/file/my_file.xml", REQUEST_METHOD => "GET" }) );
    ok( $response.body eq "Starz" , 'path with several wildcards');
}

get '/this/has/stars/*/*.*' => -> :@splat {
    @splat.join(',');
};

{
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "/this/has/stars/1/2.3", REQUEST_METHOD => "GET" }) );
    ok( $response.body eq "1,2,3" , 'path with several wildcards, splat capturing');
}
