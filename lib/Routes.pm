class Routes;
use Routes::Route;

has @.routes;
has $.default is rw;

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
    %_<code> //= { %*controllers{$!controller}.$!action(| @_, | %_) };
    @!routes.push: Routes::Route.new( pattern => @pattern, | %_ );
}

method dispatch (@chunks) {
    my @matched =  @!routes.grep: { .match(@chunks) };    
    
    if @matched {
        my $result = @matched[*-1].apply;
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

# vim:ft=perl6
