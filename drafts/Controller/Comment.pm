class Controller::Comment;

multi method GET ($id) {
    say "Comment by id $id";
}

multi method GET (Model::Topic $topic) {
    say "Comments for { $topic.WHAT } { $topic.id }";
}

multi method GET ($id, Model::Topic $topic) {
    say "Comment $id for { $topic.WHAT } { $topic.id }";
}

multi method POST () {
    say "New comment form";
}
multi method POST (%data) {
    say "Update comment by " ~ %data.perl;
}


# vim: ft=perl6
