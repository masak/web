class Routes;
use Routes::Route;

has @.routes;
has $.default is rw;

has %.controllers;

multi method add (Routes::Route $route) {
    die "Only complete routes allowed" unless $route.?is_complete;
    @!routes.push($route);
}

multi method add (@pattern, Code $code) {
    @!routes.push: Routes::Route.new( pattern => @pattern, code => $code, | %_);
}

method connect (@pattern, *%_ is rw) {
    %_<controller> //= 'Root';
    %_<action> //= 'index';
    # RAKUDO: die with Class P6protoobject already registered! if this in argh
    #%_<code> //= { %!controllers{$:controller}."$:action"(| @_, | %_) };
    @!routes.push: Routes::Route.new( pattern => @pattern, code => { %!controllers{$:controller}."$:action"(| @_, | %_) }, argh => %_ );
}

# I think it should work as I mean without this one
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
    my %param;
    %param<request> = $request;
    %param<post>    = $request.POST;
    %param<get>     = $request.GET;

    # Use param as method first because of HTML4 do not support PUT and DELETE 
    %param<method> = %param<post><request_method> || $request.request_method;

    # Do not find this .path-chunks in rack request object, 
    # but I hope we will add something like this with chunks from URI.pm
    self.dispatch($request.path-chunks, %param);
}
# vim:ft=perl6
