use v6;

use Hitomi::Stream;

grammar Hitomi::XMLGrammar {
    regex TOP { ^ <doctype>? <xmlcontent>* $ };

    token xmlcontent {
        || <element>
        || <textnode>
    };

    rule element {
        '<' <name=ident> <attrs> '/>'
        ||
        '<' <name=ident> <attrs> '>'
        <xmlcontent>+
        '</' $<name> '>'
    }

    token attrs { <attr>* }
    rule attr { $<name>=[<.ident>[':'<.ident>]?] '=' '"'
                $<value>=[<-["]>+] '"' } # '
    token ident { <+alnum + [\-]>+ }

    regex textnode { <-[<]>+ {*} }

    rule doctype { '<!DOCTYPE' <name=ident> <externalId> '>' }
    rule externalId { 'PUBLIC' <pubid> <system> }
    token pubid  { '"' $<name>=[<-["]>+] '"' }
    token system { '"' $<name>=[<-["]>+] '"' }
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
        return () unless $m<xmlcontent>;
        my @actions;
        for @($m<doctype> // []) -> $d {
            push @actions, [Hitomi::StreamEventKind::doctype, *, *];
        }
        for @($m<xmlcontent>) -> $part {
            if $part<element> -> $e {
                my $data = [~$e<name>,
                            [map {; ~.<name> => convert-entities(~.<value>) },
                                 $e<attrs><attr> ?? $e<attrs><attr>.list !! ()]
                           ];
                push @actions, [Hitomi::StreamEventKind::start, $data, *],
                               self.make-actions($e, $text),
                               [Hitomi::StreamEventKind::end, $data, *];
            }
            elsif $part<textnode> -> $t {
                my $line-num = +$text.substr(0, $t.from).comb(/\n/) + 1;
                my $pos = [Nil, $line-num, $t.from];
                my $tt = convert-entities(~$t);
                push @actions, [Hitomi::StreamEventKind::text, $tt, $pos];
            }
        }
        return @actions;
    }

    sub convert-entities($text) {
        $text.subst('&nbsp;', "\x[a0]", :g)
    }

    # RAKUDO: https://trac.parrot.org/parrot/ticket/536 makes the method
    #         override the global 'list' sub if we call it 'list'
    method llist() {
        return @!actions;
    }
}
