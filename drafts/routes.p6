# This draft was inspired by RoR Routes  
# see http://guides.rubyonrails.org/routing.html

use Routes;

my $routes = do given Routines.new {
    
    .resource: 'company';  # pattern ['company'], call company.METHOD()
    .resources: 'company'; # pattern ['company', *], call company.METHOD(| @args)

    .resource: 'company', alias => ['comapnies']; # call comapny.GET() if url '/companies';

    .resource: 'company', :controller('foo'); # call foo.GET() for GET '/company'

    .resource: 'company', has => ['offer', 'account'];
    .chain: ['company', *, 'offer' | 'account']; 
    
    # useful if strict /res/:id pattern by default.
    .connect: ['comapy', *, 'new' | 'edit' ], :resource('company'); 
    
    .connect: ['login'], :controller('user'), :action('login') ;
    .connect: [:controller, :action, *];
};

$routes.dispatch($*request);
