# Work around a rakudobug
module LolDispatch::EXPORT::DEFAULT { }

# Needs a better name
module LolDispatch {
    my @routes;
    ::LolDispatch::EXPORT::DEFAULT<!sub_trait_handler> = sub ($trait, $block, $arg) {
        # Debugging... can be removed
        warn "installing handler for $block";
        @routes.push({:route($arg[0]), :block($block)});
    }

    sub dispatch($r) is export {
        my $flag = Bool::False;
        for @routes -> $item{
            if $r.url.path ~~ $item<route> {
                $item<block>($r,$/);
                $flag = Bool::True;
                last;
            }
        }
        die "Could not dispatch {$r.url.path}" unless $flag;
    }
}

=begin usage
use LolDispatch;
use HTTP::Daemon;

sub foo($request, $match) is handler(/wtf/) {
    say 'dispatched to foo';
    say $match.perl;
}

sub item($request, $match) is handler(/^\/item\/(\d+)/) {
    say 'dispatched to item';
    say $match.perl;
}

my $request = HTTP::Request.new(
    req_url => HTTP::url.new(path => '/item/12345'),
    headers => HTTP::Headers.new( header_values => { 'Host' => 'localhost' }),
    req_method => 'GET',
);

dispatch($request);
=end

