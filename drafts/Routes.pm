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

    method res ($name, @pattern) {
        self.add_controller: $name;
        @!routes.push: Routes::Route.new(pattern => [$name], name => $name) does Routes::Resource;
    }

    multi method resource ($name)  is default { self.res: $name, [$name] }
    multi method resources ($name) is default { self.res: $name, [$name, *] }

    multi method resource (*@names)  { self.resource($_) for @names }
    multi method resources (*@names) { self.resources($_) for @names }

    method resource-chain (@pattern) { ... }
    method connect (@pattern) { ... }

    method select(@chunks) {
        my @routes = @!routes.grep: { @chunks ~~ .pattern };
        if @routes > 1 {
            my $elems = @chunks.elems;
            # RAKUDO: can`t parse .=method: {...} [perl #64268] 
            @routes = ( @routes.grep: { $elems == .pattern.elems }  or  @routes.sort: { - .pattern.elems } );
        }
        return @routes[0];
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

role Routes::Connect {
    ...
}

role Routes::ResourceChain {
    ...
}

# vim:ft=perl6
