use v6;

# Copyright (C) 2006 Edgewall Software
# All rights reserved.
#
# This software is licensed as described in the file licences/genshi/COPYING,
# which you should have received as part of this distribution. The terms
# are also available at http://genshi.edgewall.org/wiki/License.

use Test;
plan 89;

use Hitomi::Stream;
use Hitomi::XMLParser;
use Hitomi::HTMLParser;
use Hitomi::StringIO;
use Hitomi::Attrs;

constant XMLParser  = Hitomi::XMLParser;
constant HTMLParser = Hitomi::HTMLParser;
constant StringIO   = Hitomi::StringIO;
constant Attrs      = Hitomi::Attrs;

{ # test_text_node_pos_single_line
    my $text = '<elem>foo bar</elem>';
    my @events = XMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind;
    is 'foo bar', $data;
    is [Nil, 1, 6], $pos;
}

{ # test_text_node_pos_multi_line
    my $text = '<elem>foo
bar</elem>';
    my @events = XMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind;
    is "foo\nbar", $data;
    is [Nil, 1, -1], $pos;
}

{ # test_element_attribute_order
    my $text = '<elem title="baz" id="foo" class="bar" />';
    my @events = XMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[0];
    is Hitomi::StreamEventKind::start, $kind;
    my ($tag, $attrib) = @($data);
    is 'elem', $tag;
    is 'title' => 'baz', $attrib[0];
    is 'id' => 'foo',    $attrib[1];
    is 'class' => 'bar', $attrib[2];
}

{ # test_unicode_input
    my $text = "<div>\c[2013]</div>";
    my @events = XMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind;
    is "\c[2013]", $data;
}

# commented out: no Buf yet in Rakudo
##{ # test_latin1_encoded
##    my $text = "<div>\x[f6]</div>".encode('iso-8859-1');
##    my @events = XMLParser.new(StringIO.new($text), :encoding<iso-8859-1>);
##    my ($kind, $data, $pos) = @events[1];
##    is Hitomi::StreamEventKind::text, $kind;
##    is "\x[f6]", $data;
##}
    
# commented out: no Buf yet in Rakudo
##{ # test_latin1_encoded_xmldecl
##    my $text = qq[<?xml version="1.0" encoding="iso-8859-1" ?>
##    <div>\x[f6]</div>
##    ].encode'iso-8859-1');
##    my @events = XMLParser.new(StringIO.new($text), :encoding<iso-8859-1>);
##    my ($kind, $data, $pos) = @events[2];
##    is Hitomi::StreamEventKind::text, $kind;
##    is "\x[f6]", $data;
##}

{ # test_html_entity_with_dtd
    my $text = q[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>&nbsp;</html>];
    my @events = XMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[2];
    is Hitomi::StreamEventKind::text, $kind;
    is "\x[a0]", $data;
}

{ # test_html_entity_without_dtd
    my $text = '<html>&nbsp;</html>';
    my @events = XMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind;
    is "\x[a0]", $data;
}

{ # test_html_entity_in_attribute
    my $text = '<p title="&nbsp;"/>';
    my @events = XMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[0];
    is Hitomi::StreamEventKind::start, $kind;
    is "\x[a0]", $data[1]<title>;
    $kind, $data, $pos = @events[1];
    is Hitomi::StreamEventKind::end, $kind;
}

{ # test_undefined_entity_with_dtd
    my $text = q[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>&junk;</html>];
    my @events = XMLParser.new(StringIO.new($text));
    ok $! ~~ ParseError; # not sure this is how we want to catch the error
}

{ # test_undefined_entity_without_dtd
    my $text = '<html>&junk;</html>';
    my @events = XMLParser.new(StringIO.new($text));
    ok $! ~~ ParseError; # not sure this is how we want to catch the error
}

{ # test_text_node_pos_single_line
    my $text = '<elem>foo bar</elem>';
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind;
    is 'foo bar', $data;
    is [Nil, 1, 6], $pos;
}

{ # test_text_node_pos_multi_line
    my $text = '<elem>foo
bar</elem>';
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind;
    is 'foo bar', $data;
    is [Nil, 1, 6], $pos;
}

{ # test_input_encoding_text
    my $text = "<div>\x[f6]</div>".encode('iso-8859-1');
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind;
    is "\x[f6]", $data;
}

{ # test_input_encoding_attribute
    my $text = qq[<div title="\x[f6]"></div>].encode('iso-8859-1');
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[0];
    my ($tag, $attrib) = @($data);
    is Hitomi::StreamEventKind::text, $kind;
    is "\x[f6]", $attrib<title>;
}

{ # test_unicode_input
    my $text = "<div>\c[2013]</div}";
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind;
    is "\c[2013]", $data;
}

{ # test_html_entity_in_attribute
    my $text = '<p title="&nbsp;"></p>';
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[0];
    is Hitomi::StreamEventKind::start, $kind;
    is "\x[a0]", $data[1]<title>;
    $kind, $data, $pos = @events[1];
    is Hitomi::StreamEventKind::end, $kind;
}

{ # test_html_entity_in_text
    my $text = '<p>&nbsp;</p>';
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind;
    is "\x[a0]", $data;
}

{ # test_processing_instruction
    my $text = '<?php echo "Foobar" ?>';
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $td, $pos) = @events[0];
    my ($target, $data) = $td;
    is Hitomi::StreamEventKind::pi, $kind;
    is 'php', $target;
    is 'echo "Foobar"', $data;
}

{ # test_xmldecl
    my $text = '<?xml version="1.0" ?><root />';
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[0];
    my ($version, $encoding, $standalone) = $data;
    is Hitomi::StreamEventKind::decl, $kind;
    is '1.0', $version;
    ok !defined $encoding;
    is -1, $standalone;
}

{ # test_xmldecl_encoding
    my $text = '<?xml version="1.0" encoding="utf-8" ?><root />';
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[0];
    my ($version, $encoding, $standalone) = $data;
    is Hitomi::StreamEventKind::xml_decl, $kind;
    is '1.0', $version;
    is 'utf-8', $encoding;
    is -1, $standalone;
}

{ # test_xmldecl_standalone
    my $text = '<?xml version="1.0" standalone="yes" ?><root />';
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $data, $pos) = @events[0];
    my ($version, $encoding, $standalone) = $data;
    is Hitomi::StreamEventKind::xml_decl, $kind;
    is '1.0', $version;
    ok !defined $encoding;
    is 1, $standalone;
}

{ # test_processing_instruction_trailing_qmark
    my $text = '<?php echo "Foobar" ??>';
    my @events = HTMLParser.new(StringIO.new($text));
    my ($kind, $dt, $pos) = @events[0];
    my ($target, $data) = $dt;
    is Hitomi::StreamEventKind::pi, $kind;
    is 'php', $target;
    is 'echo "Foobar" ?', $data;
}

{ # test_out_of_order_tags
    my $text = '<span><b>Foobar</span></b>';
    my @events = HTMLParser.new(StringIO.new($text));
    is 5, +@events;
    is [StreamEventKind::start, ['span', []]], @events[0][0,1];
    is [StreamEventKind::start, ['b',    []]], @events[1][0,1];
    is [StreamEventKind::text,  ['Foobar'  ]], @events[2][0,1];
    is [StreamEventKind::end,   ['b',      ]], @events[3][0,1];
    is [StreamEventKind::end,   ['span',   ]], @events[4][0,1];  
}

{ # test_out_of_order_tags2
    my $text = '<span class="baz"><b><i>Foobar</span></b></i>';
    my @events = HTMLParser.new(StringIO.new($text));
    is 7, +@events;
    is [StreamEventKind::start, ['span', Attrs.new(:class<baz>)]],
                                              @events[0][0,1];
    is [StreamEventKind::start, ['b',    []]], @events[1][0,1];
    is [StreamEventKind::start, ['i',    []]], @events[2][0,1];
    is [StreamEventKind::text,  ['Foobar'  ]], @events[3][0,1];
    is [StreamEventKind::end,   ['i',      ]], @events[4][0,1];
    is [StreamEventKind::end,   ['b',      ]], @events[5][0,1];
    is [StreamEventKind::end,   ['span',   ]], @events[6][0,1];  
}

{ # test_out_of_order_tags3
    my $text = '<span><b>Foobar</i>';
    my @events = HTMLParser.new(StringIO.new($text));
    is 5, +@events;
    is [StreamEventKind::start, ['span', []]], @events[0][0,1];
    is [StreamEventKind::start, ['b',    []]], @events[1][0,1];
    is [StreamEventKind::text,  ['Foobar'  ]], @events[2][0,1];
    is [StreamEventKind::end,   ['b',      ]], @events[3][0,1];
    is [StreamEventKind::end,   ['span',   ]], @events[4][0,1];  
}

{ # test_hex_charref
    my $text = '<span>&#x27;</span>';
    my @events = HTMLParser.new(StringIO.new($text));
    is 3, +@events;
    is [StreamEventKind::start, ['span', []]], @events[0][0,1];
    is [StreamEventKind::text,  ["'"       ]], @events[1][0,1];
    is [StreamEventKind::end,   ['span'    ]], @events[2][0,1];
}
