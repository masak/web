use Hitomi::StreamEventKind;

grammar Hitomi::Interpolation::Grammar {
    regex TOP { ^ <chunk>* $ }
    regex chunk { <plain> || <expr> }

    regex plain { [<!after '$'> .]+ }
    regex expr { '$' [ <identifier> | <block> ] }

    regex ident { <.alpha> \w* }
    regex identifier { <.ident> [ <.apostrophe> <.ident> ]* }
    token apostrophe { <[ ' \- ]> }

    regex block { '{' <-[{}]>+ '}' }
}

# Note: It _is_ possible for the above grammar to fail, even though it's
#       probably not very desirable that it can. An example of a failing
#       input is '$'. The way to fix this would likely be (1) see what
#       Genshi does about broken input, (2) write Hitomi tests to do the
#       same, (3) improve the grammar.

sub interpolate($text, $filepath, $lineno = -1, $offset = 0,
                $lookup = 'strict') {

    # TODO: Make it impossible to fail here. See the above note.
    return $text
        unless Hitomi::Interpolation::Grammar.parse($text);

    return gather for @($<chunk> // []) -> $chunk {
        my $pos = [$filepath, $lineno, $offset];
        if $chunk<plain> -> $plain {
            take [Hitomi::StreamEventKind::text, ~$plain, $pos];
        }
        elsif $chunk<expr> -> $expr {
            take [Hitomi::StreamEventKind::expr, ~$expr, $pos];
        }
    }
}
