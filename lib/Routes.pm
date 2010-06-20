class Routes;
use Routes::Route;

has @.routes;

# RAKUDO: invoke() not implemented in class 'Perl6Role' on 01-6 test
# TODO: find out is it rakudobug or not
#has Callable $.default is rw;

has $.default is rw;

multi method add (Routes::Route $route) {
    die "Only complete routes allowed" unless $route.?is_complete;
    @!routes.push($route);
}

multi method add (@pattern, Code $code) {
    @!routes.push: Routes::Route.new( pattern => @pattern, code => $code, |%_);
}

method connect (@pattern, *%opts) {
    # RAKUDO: die with 'Class P6protoobject already registered!' if this just in argh
    #%_<code> //= { %!controllers{$:controller}."$:action"(| @_, | %_) };
    say 'connect:' ~ @pattern.perl ~ ' ' ~  %opts.perl;
    @!routes.push: Routes::Route.new( pattern => @pattern, code => { %:controllers{$:controller}."$:action"(| @_, | %_) }, named-args => %opts );
}

# RAKUDO: Ambiguous dispatch [perl #64922]
# workaround:
multi method dispatch (@chunks) { self.dispatch(@chunks, Hash.new) }

multi method dispatch (@chunks, $env) {
#multi method dispatch (@chunks, $env?) {

    my @matched =  @!routes.grep: { .match(@chunks) };
    # my @matched = @!routes».match; # yay?!

    if @matched {
        my $result = @matched[*-1].apply($env);
        .clear for @!routes; 
        return $result;
    }
    elsif defined $.default {
        $.default();
    }
    else {
        return Failure;
    }
}

multi method dispatch ($env) {
    # Do not find this .path-chunks in Rack request object, 
    # but I hope we will add something like this worked like .chunks in URI.pm
    self.dispatch($env.path-chunks, $env);
}
# vim:ft=perl6
