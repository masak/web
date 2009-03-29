class Routes {
    has @.routes;
    has %.controllers;

    method add_route (@pattern, $route) {
        @!routes.push: Routes::Route.new(@pattern, $route);
    }

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
        self.add_rote: [$name, *], Routes::Resource.new($name);
    }

    multi method resource (*@names) { self.resource($_) for @names }

    method sort {
        @!routes = @!routes.sort: { $^a.pattern.elems > $^b.pattern.elems };
    }
}

class Routes::Route {
    has @.pattern;
    has $.route;
    has $.alias;
}

class Routes::Resource {
    has $.name;

    method call ($request) {
        ...
    }
}
