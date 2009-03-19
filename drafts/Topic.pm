class Topic; # is Forest::Model
has $.id;
has $.title;
has $.body;

method find ($id) {
    $!id = $id;
    # find data by id, and fill object
    return self;
}

# vim: ft=perl6
