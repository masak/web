class Routes {
    has @.routes;

    method add (@pattern, $route) {
        @!routes.push: Routes::Route.new(@pattern, $rote);
    }

    multi method resource ($name) is default {
        self.add: [$name, *], Routes::Resource.new($name);
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
