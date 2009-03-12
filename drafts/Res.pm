class Res {
    proto method GET {
        say "not valid"
    }

    multi method GET () {
        say "Index";
    }

    multi method GET (Int $id) {
        say "Show Res $id";
        say "with tags: " ~ %_<tags> if %_<tags>;
    }

    # TODO: new and edit action broke RESTfulness, 
    # why not use PUT and POST without params instead?
    # Need to ask someone who now REST better.
    multi method GET ($action where "new") {
        say "Form for new Res";
    }
    multi method GET (Int $id, $action where "edit") {
        say "Form for edit Res $id";
    }

    multi method GET (Int $id, $action) {
        say "$action Res $id"
    }
}

for Res {
    .GET;
    .GET(1);
    .GET(2, tags => ['foo', 'bar'] ); # ?tags=foo&tags=bar
    .GET('new');
    .GET(3, 'edit');
    .GET(4, 'edit');
}
# vim:ft=perl6
