role http-handler {
}

# Needs a better name
module LolDispatch {
    my @routes;
    multi trait_auxiliary:<is>(http-handler $trait, $block, $arg) is export {
        @routes.push({:route($arg[0]), :block($block)});
    }

    sub dispatch($r) is export {
        for @routes -> $item{
            if $r.url.path ~~ $item<route> {
                my $ret = $item<block>($r,$/);
                return $ret;
            }
        }
        warn "Could not dispatch {$r.url.path}";
    }
}

=begin usage
use LolDispatch;
use HTTP::Daemon;

sub foo($request, $match) is http-handler(/wtf/) {
    say 'dispatched to foo';
    say $match.perl;
}

sub item($request, $match) is http-handler(/^\/item\/(\d+)/) {
    say 'dispatched to item';
    say $match.perl;
}

my $request = HTTP::Request.new(
    req_url => HTTP::url.new(path => '/item/12345'),
    headers => HTTP::Headers.new( header_values => { 'Host' => 'localhost' }),
    req_method => 'GET',
);

dispatch($request);
=end usage

