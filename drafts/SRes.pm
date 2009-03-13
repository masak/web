role Chain { ... }
class Foo { has $foo; }

class Res {
    # RAKUDO: $?CLASS not implemented yet
    # has Str $.path = $?CLASS.lc;
    # this is not useful now, because we need resource table outside

    multi method GET () {
        say "Index";
    }

    multi method GET (Int $id) {
        say "Show Res $id";
        say "with tags: " ~ %_<tags> if %_<tags>;
    }

    multi method PUT (Int $id) {
        say "Form for edit $id";
    }
    multi method PUT (Int $id, %data) {
        say "Update Res $id by " ~ %data.perl;
    }

    multi method POST () {
        say "Form for new Res";
    }
    multi method POST (%data) {
        say "Create Res with " ~ %data.perl;
    }

    multi method DELETE (Int $id) {
        say "Delete Res $id";
    }

    multi method DELETE {
        say "Delete all Reses";
    }

    method Chain ($id, OtherRes $next ) {
        use Foo;
        my $foo = Foo.new(foo => $id);
        return ($rest, $foo);
    }
}

class OtherRes {
    multi method GET (Foo $id) {
    }
    multi method GET ($id) {
    }
}

for Res {
    .GET;
    .GET(1);
    .GET(2, tags => ['foo', 'bar']); # ?tags=foo&tags=bar
    .PUT(3);
    .PUT(3, {foo => 'bar'});
    .POST;
    .POST({foo => 'bar'});
    .DELETE(1);
    .DELETE;
    my ($method, @args) = 'GET', 1;
    ."$method"(| @args);
}
# vim:ft=perl6
