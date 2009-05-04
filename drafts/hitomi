use v6;

grammar XML {
    regex TOP { ^ <pi>* <xmlcontent>+ {*} $ };

    token xmlcontent {
        | <node>           {*} #= node
        | <empty>          {*} #= empty
        | <content>        {*} #= content
    };

    rule node {
        '<' <name=ident> <attrs> '>'
        <xmlcontent>+
        '</' $<name> '>'
        {*}
    }

    rule pi { '<!' <.ident> <.ident> '>' };

    rule empty   { '<'  <name=ident> <attrs> '/>' {*} };

    token attrs { <attr>* {*} }
    rule attr { $<name>=[<.ident>[':'<.ident>]?] '=' '"' $<value>=[<-["]>+] '"' }

    token ident { <+alnum + [\-]>+ }

    regex content { <-[<]>+ {*} }
};
class XML::Actions {
    my $h = -> $/ {
        make [~] gather {
            for $/.chunks{
                if .key eq '~' {
                    take .value;
                } else {
                    take .value.ast;
                }
            }
        }
    }
    method TOP($/) {
        $h($/);
    }

    method xmlcontent($/, $key) {
        $h($/);
    }

    method node($/) {
        if $<attrs><attr> {
            for $<attrs><attr> -> $a {
                if $a<name> eq "pe:if" {
                    make eval(~$a<value>) ?? matching-if($/) !! q[];
                    return;
                }
                elsif $a<name> ~~ /^ 'pe:'/ {
                    make "Unknown 'pe:' attribute!";
                    return;
                }
            }
        }
        $h($/);
    }

    method empty($/) {
        $h($/);
    }

    method attrs($/) {
        $h($/);
    }
    method content($/) {
        make ~$/;
    }

    sub matching-if($/) {
        return $/.ast;
    }
}

# RAKUDO: Arguably wrong that this has to be here and not in the class.
#         [perl #65238]
sub links() {
    return [
        {
            :url<http://ihrd.livejournal.com/>,
            :title("ihrd's blog"),
            :username<ihrd>,
            :time(1240904601)
        },
        {   :url<http://blogs.gurulabs.com/stephen/>,
            :title("Tene's blog"),
            :username<Tene>,
            :time(1240905184),
        },
        {   :url<http://use.perl.org/~masak/journal/>,
            :title("masak's blog"),
            :username<masak>,
            :time(1240905293),
        },
    ];
}


my $xml = $*IN.slurp;
my $result = XML.parse($xml, :action(XML::Actions.new()));
print $result.ast;

# vim: ft=perl6
