use Hitomi::StreamEventKind;

sub escape($text, :$quotes = True) {
    $text; # TODO
}

class Hitomi::XMLSerializer {
    has @!filters;

    method serialize($stream) {
        return join '', [~] gather for $stream.llist {
            my ($kind, $data, $pos) = @($_);
            if ($kind ~~ Hitomi::StreamEventKind::start
                       | Hitomi::StreamEventKind::empty) {
                my ($tag, $attribs) = @($data);
                take '<';
                take $tag;
                for @($attribs) -> $attrib {
                    my ($attr, $value) = @($attrib);
                    take for ' ', $attr, q[="], escape($value), q["];
                }
                take $kind ~~ Hitomi::StreamEventKind::empty ?? '/>' !! '>';
            }
            elsif ($kind ~~ Hitomi::StreamEventKind::end) {
                take sprintf '</%s>', $data;
            }
            else { # TODO More types
                take escape($data, :!quotes);
            }
        }
    }
}

class Hitomi::XHTMLSerializer is Hitomi::XMLSerializer {
}

class Hitomi::HTMLSerializer {
}

class Hitomi::TextSerializer {
}

sub get_serializer($method, *%_) {
    my $class = ( :xml(   Hitomi::XMLSerializer),
                  :xhtml( Hitomi::XHTMLSerializer),
                  :html(  Hitomi::HTMLSerializer),
                  :text(  Hitomi::TextSerializer) ){$method.lc};
    return $class.new(|%_);
}

