class Routes {
    has @.routes;
    has %.controllers;

    method add_controller ($name is copy) {
        unless %!controllers{$name} {
            $name = 'Controller::' ~ $name.capitalize; 
            use $name;
            %!controllers{$name} = "$name".new;
            CATCH { ... }
        }
    }

    multi method resource ($name) is default {
        self.add_controller: $name;
        @!routes.push: Routes::Route.new(pattern => [$name, *], name => $name) does Routes::Resource;
    }

    multi method resource (*@names) { self.resource($_) for @names }

    method select(@chunks) {
        my @matched_routes = @!routes.grep: { @chunks ~~ .pattern };
        @matched_routes = @matched_routes.sort: { - .pattern.elems } if @matched_routes > 1;
        # mb 'equal elems or bigest' better here
        return @matched_routes[0];
    }

    method dispatch ($request) {
        my @chunks = $request.uri.chunks;
        my $route  = self.select(@chunks);
        $route.handle($!controller{($route.controller || $route.name)}, $request);
    }
}

class Routes::Route {
    has $.name;
    has @.pattern;
    has $.controller;
    has $.action;
    has $.alias;
}

role Routes::Resource {
    method handle ($resource, $request) {
        my $method = $request.method;
        my @chunks = $request.uri.chunks;
        my %data   = $request.data;

        my @args = @chunks[1..*-1];
        @args.push(\%data) if %data;

        $resource."$method"(| @args); 
    }
    
}
# vim:ft=perl6
