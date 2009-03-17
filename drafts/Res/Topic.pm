class Res::Topic;

multi method GET () {
    say "Topics";
}

multi method GET ($id) {
    say "Topic id: $id";
}

multi method POST () {
    say "New topic form";
}
multi method POST (%data) {
    say "Update topic by " ~ %data.perl;
}

method Link ($id, *@rest_chunks) {
    my $topic = Topic.new.find($id);
    my $rest = @rest_chunks;
    
    # RAKUDO: multiple return do not work properly [perl #63912]
    return ($rest, [$topic]);
}

# vim: ft=perl6
