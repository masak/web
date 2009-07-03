use v6;

class Hitomi::HTMLParser {
    # RAKUDO: https://trac.parrot.org/parrot/ticket/536 makes the method
    #         override the global 'list' sub if we call it 'list'
    method llist() {
        return ();
    }
}
