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

    method new($text, $filename?, $encoding?) {
        return self.bless(*, :$text);
    }

    submethod make-events(Match $m, $text) {
        return () unless $m<xmlcontent>;
        my @events;
        for @($m<doctype> // []) -> $d {
            push @events, [Hitomi::StreamEventKind::doctype, *, *];
        }
        for @($m<xmlcontent>) -> $part {
            if $part<element> -> $e {
                my $data = [~$e<name>,
                            [map {; ~.<name> => convert-entities(~.<value>) },
                                 $e<attrs><attr> ?? $e<attrs><attr>.list !! ()]
                           ];
                push @events, [Hitomi::StreamEventKind::start, $data, *],
                              self.make-events($e, $text),
                              [Hitomi::StreamEventKind::end, ~$e<name>, *];
            }
            elsif $part<textnode> -> $t {
                my $line-num = +$text.substr(0, $t.from).comb(/\n/) + 1;
                my $pos = [Nil, $line-num, $t.from];
                my $tt = convert-entities(~$t);
                push @events, [Hitomi::StreamEventKind::text, $tt, $pos];
            }
        }
        return @events;
    }

    sub convert-entities($text) {
        die "Unrecognized entity $0"
            if $text ~~ / ('&' <!before nbsp> \w+ ';') /;
        $text.subst('&nbsp;', "\x[a0]", :g)
    }

    # RAKUDO: https://trac.parrot.org/parrot/ticket/536 makes the method
    #         override the global 'list' sub if we call it 'list'
    method llist() {
        Hitomi::XMLGrammar.parse($!text) or die "Couldn't parse $!text";
        my @actions = self.make-events($/, $!text);
        return @actions;
    }
}
