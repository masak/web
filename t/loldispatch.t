use v6;

use Test;
use LolDispatch;

plan *;

# make some mock objects for testing
class HTTP::Request
{
	has $.url;
}

class HTTP::URL
{
	has $.path;
}

my $box = '';

# tests for static paths

sub first($r, $m) is http-handler(/test/) {
	$box = 'first';
}

sub second($r, $m) is http-handler('/index.html')
{
	$box = 'second';
}

sub third($r, $m) is http-handler('/')
{
	$box = 'index';
}

my @static;
@static.push({:path('/test/'), :test('first')});
@static.push({:path('/index.html'), :test('second')});
@static.push({:path('/'), :test('index')});

for @static -> $item {
	my $path = HTTP::URL.new(path => $item<path>);
	my $request = HTTP::Request.new(url => $path);
	dispatch($request);
	is($box, $item<test>, 'static test passed');
}

my $testid;

# test dynamic path

sub blog($r, $m) is http-handler(/\/item\/(\d+)/) {
	$testid = $m[0].Int;
}

my $path = HTTP::URL.new(path => '/item/12345');
my $request = HTTP::Request.new(url => $path);

dispatch($request);

is($testid, '12345', 'dynamic path matches');
