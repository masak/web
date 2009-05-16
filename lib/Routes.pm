class Routes;
use Routes::Route;

has @.routes;

# RAKUDO: invoke() not implemented in class 'Perl6Role' on 01-6 test
# TODO: find out is it rakudobug or not
#has Callable $.default is rw;

has $.default is rw;

has %.controllers;

multi method add (Routes::Route $route) {
    die "Only complete routes allowed" unless $route.?is_complete;
    @!routes.push($route);
}

multi method add (@pattern, Code $code) {
    @!routes.push: Routes::Route.new( pattern => @pattern, code => $code, |%_);
}

method connect (@pattern, *%_ is rw) {
    %_<controller> //= 'Root';
    %_<action> //= 'index';
    # RAKUDO: die with 'Class P6protoobject already registered!' if this just in argh
    #%_<code> //= { %!controllers{$:controller}."$:action"(| @_, | %_) };
    say 'connect:' ~ @pattern.perl ~ ' ' ~  %_.perl;
    @!routes.push: Routes::Route.new( pattern => @pattern, code => { %!controllers{$:controller.ucfirst}."$:action"(| @_, | %_) }, argh => %_ );
}

# RAKUDO: Ambiguous dispatch [perl #64922]
# workaround:
multi method dispatch (@chunks) { self.dispatch(@chunks, Hash.new) }

multi method dispatch (@chunks, %param) {
#multi method dispatch (@chunks, %param?) {
    my @matched =  @!routes.grep: { .match(@chunks) };    
    
    if @matched {
        my $result = @matched[*-1].apply(%param);
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

# draft
multi method dispatch ($request) {
    my %params;
    %params<request> = $request;
    %params<post>    = $request.POST;
    %params<get>     = $request.GET;

    # Use param as method first because HTML4 does not support PUT and DELETE
    %params<method> = %params<post><request_method> || $request.request_method;

    # Do not find this .path-chunks in rack request object, 
    # but I hope we will add something like this worked like .chunks in URI.pm
    self.dispatch($request.path-chunks, %params);
}
# vim:ft=perl6
