# This draft was inspired by RoR Routes
# see http://guides.rubyonrails.org/routing.html

use Routes;

my $routes = do given Routes.new {
    .connect: ['foo', :action ];
    # the same as:
    .add: ['foo', :action ], :conroller('Root'), { %*controller{$:controller}."{$:action}"(@_) }

    .connect: [:controller, :action, *], :slurp; # call controller.action(@_)
}

use Routes::Resources;

my $routes = do given Routes.new does Routes::Resources {

    .resource: 'company';  # pattern ['company'], call company.METHOD()
    .resources: 'company'; # pattern ['company', *], call company.METHOD(| @args)

    .resource: 'company', plural => 'comapnies'; # call comapny.GET() if url '/companies';
    # mb pattern like: [[ 'companies' ], ['company', *]]?

    .resource: 'company', :controller('foo'); # call foo.GET() for GET '/company'

    .resource: 'company', has_one => ['offer', 'account'], has_many => {
        .resources: 'member', plural => 'members';
    };

    .resources-chain: ['company', *, ['offer', 'account']];
};

$routes.dispatch($*request);

# vim: ft=perl6
