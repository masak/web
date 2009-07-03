use v6;

use Hitomi::Stream;

grammar Hitomi::XMLGrammar {
    regex TOP { ^ <xmlcontent>* $ };

    token xmlcontent {
        || <element>
        || <empty>
        || <textnode>
    };

    rule element {
        '<' <name=ident> <attrs> '>'
        <xmlcontent>+
        '</' $<name> '>'
    }

    rule empty   { '<'  <name=ident> <attrs> '/>' }

    token attrs { <attr>* }
    rule attr { $<name>=[<.ident>[':'<.ident>]?] '=' '"'
                $<value>=[<-["]>+] '"' } # '
    token ident { <+alnum + [\-]>+ }

    regex textnode { <-[<]>+ {*} }
}

class Hitomi::XMLParser {
    has $!text;
    has @!actions;

    method new($text) {
        Hitomi::XMLGrammar.parse($text) or die "Couldn't parse $text";
        my @actions = self.make-actions($/, $text);
        return self.bless(*, :$text, :@actions);
    }

    submethod make-actions(Match $m, $text) {
        my @actions;
        for @($m<xmlcontent>) -> $part {
            if $part<element> -> $e {
                push @actions, [Hitomi::StreamEventKind::start, '', *];
                push @actions, self.make-actions($e, $text);
                push @actions, [Hitomi::StreamEventKind::end, '', *];
            }
            elsif $part<textnode> -> $t {
                my $line-num = +$text.substr(0, $t.from).comb(/\n/) + 1;
                my $pos = [Nil, $line-num, $t.from];
                push @actions, [Hitomi::StreamEventKind::text, ~$t, $pos];
            }
        }
        return @actions;
    }

    # RAKUDO: https://trac.parrot.org/parrot/ticket/536 makes the method
    #         override the global 'list' sub if we call it 'list'
    method llist() {
        return @!actions;
    }
}
