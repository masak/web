use v6;

module Tags::EXPORT::DEFAULT { }

module Tags {
    our @frames;

    # XXX: The below list used to contain 'map', but I removed it because it
    #      screwed up code elsewhere. -- masak

    my @nocollapse = <textarea>;
    # Hide it in a sub to work around a bug
    sub _setup {
        for <
        h1 h2 h3 h4 h5 h6 p br hr ol ul li dl dt dd menu code var strong em tt
        u i b blockquote pre img a address cite samp dfn html head base body
        link nextid title meta kbd start_html end_html input select option
        comment charset escapehtml div table caption th td tr tr sup sub
        strike applet param nobr embed basefont style span layer ilayer font
        frameset frame script small big area abbr acronym bdo col colgroup
        del fieldset iframe ins label legend noframes noscript object optgroup
        q thead tbody tfoot blink fontsize center textfield textarea filefield
        password_field hidden checkbox checkbox_group submit reset defaults
        radio_group popup_menu button autoescape scrolling_list image_button
        start_form end_form startform endform start_multipart_form
        end_multipart_form isindex tmpfilename uploadinfo url_encoded
        multipart form canvas
        > -> $tag {
            ::Tags{$tag} = sub ($c?, *%attrs) {
                _tag($tag, $c, :attrs{%attrs});
            }
            ::Tags::EXPORT::DEFAULT{$tag} = ::Tags{$tag};
        }
    }
    _setup();

    sub show(&code) is export(:DEFAULT) {
        new_buffer_frame();
        &code();
        return end_buffer_frame();
    }

    sub _tag(Str $tag is rw, $body, *%named-args) {
        my %attrs = %named-args<attrs>;
        my $buf = "\n" ~ '  ' x (@frames.elems() - 1) ~ "<$tag";
        for %attrs.kv -> $k, $v {
            $buf ~= " $k='$v'";
        }
        given $body {
            when Failure {
                if $tag ~~ @nocollapse {
                    $buf ~= "></$tag>";
                }
                else {
                    $buf ~= '/>';
                }
            }
            when Code {
                $buf ~= '>';
                new_buffer_frame();
                my $ret = $body();
                my $frame = end_buffer_frame();
                if $frame.chars() > 0 {
                    $buf ~= $frame;
                }
                else {
                    $buf ~= $ret;
                }
                $buf ~= "\n" ~ '  ' x (@frames.elems() - 1) ~ "</$tag>";
            }
            when Str {
                $buf ~= ">$body</$tag>";
            }
        }
        outs($buf);
        return '';
    }

    sub outs($text) is export(:DEFAULT) {
        @frames[0] ~= ($text);
    }

    sub new_buffer_frame {
        @frames.unshift('');
    }

    sub end_buffer_frame {
        @frames.shift();
    }

    class Web::Tags::Buffer {
        has $.data is rw;
        method append($text) {
            $.data ~= $text;
        }
    }

}

