use v6;
our @frames;

sub show(&code) is export() {
    new_buffer_frame();
    &code();
    return end_buffer_frame();
}

sub ul(&c) is export() {
    _tag('ul', &c);
}

sub li(&c) is export() {
    _tag('li', &c);
}

sub html(&c) is export() {
    _tag('html', &c);
}

sub _tag(Str $tag, &code) {
    my $buf = "\n<$tag>";
    new_buffer_frame();
    my $ret = &code();
    my $frame = end_buffer_frame();
    if $frame.chars() > 0 {
        $buf ~= $frame;
    }
    else {
        $buf ~= $ret;
    }
    $buf ~= "</$tag>";
    outs($buf);
    return '';
}

sub outs($text) is export() {
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
# vim:ft=perl6
