use v6;

use Test;
plan 3;

class C::Root {
    method foo   { 'foo: ' ~ $^d }
    method index { 'index' }
}

class C::User {
    method show  { 'show user'}
    method index { 'index of users' }
}


use Routes;
given my $r = Routes.new( controllers => {Root => C::Root.new, User => C::User.new} ) {
    .connect: [:controller, :action];
    .connect: [:controller];
    .connect: [:action, /^ \d $/];
}

is $r.dispatch(['foo', 3]), 
    'foo: 3', 
    'Connect call action on the default (Root) controller';

is $r.dispatch(['user', 'show']), 
    'show user', 
    'Connect to selected controller and action';

# TOFIX: %!argh cleared by .clear now, and this is remove defaults.
is $r.dispatch(['user']), 
    'index user', 
    'Connect to selected controller, call default(index) action';

# vim:ft=perl6
