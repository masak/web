use Res;
use Topic;

class Res::Topic is Res {

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
        return ('next', @rest_chunks, $topic);
    }

}
# vim: ft=perl6
