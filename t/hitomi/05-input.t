use v6;

# Copyright (C) 2006 Edgewall Software
# All rights reserved.
#
# This software is licensed as described in the file licences/genshi/COPYING,
# which you should have received as part of this distribution. The terms
# are also available at http://genshi.edgewall.org/wiki/License.

use Test;
plan 77;

use Hitomi::Stream;
use Hitomi::XMLParser;
use Hitomi::HTMLParser;
use Hitomi::Attrs;
use Hitomi::Input;

constant XMLParser  = Hitomi::XMLParser;
constant HTMLParser = Hitomi::HTMLParser;
constant Attrs      = Hitomi::Attrs;

{ # test_text_node_pos_single_line
    my $text = '<elem>foo bar</elem>';
    my @events = (XMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
    is 'foo bar', $data, 'the text is "foo bar"';
    is [Nil, 1, 6], $pos, '...on position 6 on line 1';
}

{ # test_text_node_pos_multi_line
    my $text = '<elem>foo
bar</elem>';
    my @events = (XMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
    is "foo\nbar", $data, 'the text is "foo\nbar"';
    is [Nil, 1, 6], $pos, '...on position 6 on line 1';
    # Genshi differs here due to Expat, see the explanation on
    # http://genshi.edgewall.org/browser/trunk/genshi/input.py#L179
}

{ # test_element_attribute_order
    my $text = '<elem title="baz" id="foo" class="bar" />';
    my @events = (XMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[0];
    is Hitomi::StreamEventKind::start, $kind, 'got a start event';
    my ($tag, $attrib) = @($data);
    is 'elem', $tag, 'the tag has name "elem"';
    is 'title' => 'baz', $attrib[0], q[first attr is 'title="baz"'];
    is 'id' => 'foo',    $attrib[1], q[second attr is 'id="foo"'];
    is 'class' => 'bar', $attrib[2], q[third attr is 'class="bar"'];
}

{ # test_unicode_input
    my $text = "<div>\c[2013]</div>";
    my @events = (XMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
    is "\c[2013]", $data, 'the character survived';
}

# commented out: no Buf yet in Rakudo
##{ # test_latin1_encoded
##    my $text = "<div>\x[f6]</div>".encode('iso-8859-1');
##    my @events = (XMLParser.new($text, :encoding<iso-8859-1>)).llist;
##    my ($kind, $data, $pos) = @events[1];
##    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
##    is "\x[f6]", $data, 'the character survived';
##}
    
# commented out: no Buf yet in Rakudo
##{ # test_latin1_encoded_xmldecl
##    my $text = qq[<?xml version="1.0" encoding="iso-8859-1" ?>
##    <div>\x[f6]</div>
##    ].encode'iso-8859-1');
##    my @events = (XMLParser.new($text, :encoding<iso-8859-1>)).llist;
##    my ($kind, $data, $pos) = @events[2];
##    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
##    is "\x[f6]", $data, 'the character survived';
##}

{ # test_html_entity_with_dtd
    my $text = q[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>&nbsp;</html>];
    my @events = (XMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[2];
    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
    is "\x[a0]", $data, 'the entity was turned into a character';
}

{ # test_html_entity_without_dtd
    my $text = '<html>&nbsp;</html>';
    my @events = (XMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
    is "\x[a0]", $data, 'the entity was turned into a character';
}

{ # test_html_entity_in_attribute
    my $text = '<p title="&nbsp;"/>';
    my @events = (XMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[0];
    is Hitomi::StreamEventKind::start, $kind, 'got a start event';
    $data //= [*, {}];
    is "\x[a0]", $data[1]<title>, 'the entity was turned into a character';
    $kind, $data, $pos = @events[1];
    is Hitomi::StreamEventKind::end, $kind, 'got an end event';
}

{ # test_undefined_entity_with_dtd
    my $text = q[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>&junk;</html>];
    my @events = (XMLParser.new($text)).llist;
    # XXX not sure this is how we want to catch the error
    ok $! ~~ ParseError, 'got a parse error';
}

{ # test_undefined_entity_without_dtd
    my $text = '<html>&junk;</html>';
    my @events = (XMLParser.new($text)).llist;
    # XXX not sure this is how we want to catch the error
    ok $! ~~ ParseError, 'got a parse error';
}

{ # test_text_node_pos_single_line
    my $text = '<elem>foo bar</elem>';
    my @events = (HTMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
    is 'foo bar', $data, 'the text is "foo bar"';
    is [Nil, 1, 6], $pos, '...on position 6 on line 1';
}

{ # test_text_node_pos_multi_line
    my $text = '<elem>foo
bar</elem>';
    my @events = (HTMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
    is "foo\nbar", $data, 'the text is "foo bar"';
    is [Nil, 1, 6], $pos, '...on position 6 on line 1';
}

# commented out: no Buf yet in Rakudo
##{ # test_input_encoding_text
##    my $text = "<div>\x[f6]</div>".encode('iso-8859-1');
##    my @events = (HTMLParser.new($text)).llist;
##    my ($kind, $data, $pos) = @events[1];
##    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
##    is "\x[f6]", $data, 'the character survived';
##}

# commented out: no Buf yet in Rakudo
##{ # test_input_encoding_attribute
##    my $text = qq[<div title="\x[f6]"></div>].encode('iso-8859-1');
##    my @events = (HTMLParser.new($text)).llist;
##    my ($kind, $data, $pos) = @events[0];
##    my ($tag, $attrib) = @($data);
##    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
##    is "\x[f6]", $attrib<title>, 'the character survived';
##}

{ # test_unicode_input
    my $text = "<div>\c[2013]</div}";
    my @events = (HTMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
    is "\c[2013]", $data, 'the character survived';
}

{ # test_html_entity_in_attribute
    my $text = '<p title="&nbsp;"></p>';
    my @events = (HTMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[0];
    is Hitomi::StreamEventKind::start, $kind, 'got a start event';
    $data //= [*, {}];
    is "\x[a0]", $data[1]<title>, 'the entity was turned into a character';
    $kind, $data, $pos = @events[1];
    is Hitomi::StreamEventKind::end, $kind, 'got an end event';
}

{ # test_html_entity_in_text
    my $text = '<p>&nbsp;</p>';
    my @events = (HTMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[1];
    is Hitomi::StreamEventKind::text, $kind, 'got a text event';
    is "\x[a0]", $data, 'the entity was turned into a character';
}

{ # test_processing_instruction
    my $text = '<?php echo "Foobar" ?>';
    my @events = (HTMLParser.new($text)).llist;
    my ($kind, $td, $pos) = @events[0];
    my ($target, $data) = $td;
    is Hitomi::StreamEventKind::pi, $kind, 'got a pi event';
    is 'php', $target, 'the target is "php"';
    is 'echo "Foobar"', $data, q[the data is 'echo "Foobar"'];
}

{ # test_xmldecl
    my $text = '<?xml version="1.0" ?><root />';
    my @events = (HTMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[0];
    my ($version, $encoding, $standalone) = $data;
    is Hitomi::StreamEventKind::xml-decl, $kind, 'got an xml-decl event';
    is '1.0', $version, 'the version is 1.0';
    ok !defined $encoding, 'no encoding';
    is -1, $standalone, 'not standalone';
}

{ # test_xmldecl_encoding
    my $text = '<?xml version="1.0" encoding="utf-8" ?><root />';
    my @events = (HTMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[0];
    my ($version, $encoding, $standalone) = $data;
    is Hitomi::StreamEventKind::xml-decl, $kind, 'got an xml-decl event';
    is '1.0', $version, 'the version is 1.0';
    is 'utf-8', $encoding, 'the encoding is "utf-8"';
    is -1, $standalone, 'not standalone';
}

{ # test_xmldecl_standalone
    my $text = '<?xml version="1.0" standalone="yes" ?><root />';
    my @events = (HTMLParser.new($text)).llist;
    my ($kind, $data, $pos) = @events[0];
    my ($version, $encoding, $standalone) = $data;
    is Hitomi::StreamEventKind::xml-decl, $kind, 'got an xml-decl event';
    is '1.0', $version, 'the version is 1.0';
    ok !defined $encoding, 'no encoding';
    is 1, $standalone, 'standalone';
}

{ # test_processing_instruction_trailing_qmark
    my $text = '<?php echo "Foobar" ??>';
    my @events = (HTMLParser.new($text)).llist;
    my ($kind, $dt, $pos) = @events[0];
    my ($target, $data) = $dt;
    is Hitomi::StreamEventKind::pi, $kind, 'got a pi event';
    is 'php', $target, 'the target is "php"';
    is 'echo "Foobar" ?', $data, 'the data has one final "?"';
}

{ # test_out_of_order_tags
    my $text = '<span><b>Foobar</span></b>';
    my @events = (HTMLParser.new($text)).llist;
    is 5, +@events, 'got 5 events';
    @events ||= [] xx 5;
    is [Hitomi::StreamEventKind::start, ['span', []]], @events[0][0,1], 'o1[1]';
    is [Hitomi::StreamEventKind::start, ['b',    []]], @events[1][0,1], 'o1[2]';
    is [Hitomi::StreamEventKind::text,  ['Foobar'  ]], @events[2][0,1], 'o1[3]';
    is [Hitomi::StreamEventKind::end,   ['b',      ]], @events[3][0,1], 'o1[4]';
    is [Hitomi::StreamEventKind::end,   ['span',   ]], @events[4][0,1], 'o1[5]';
}

{ # test_out_of_order_tags2
    my $text = '<span class="baz"><b><i>Foobar</span></b></i>';
    my @events = (HTMLParser.new($text)).llist;
    is 7, +@events, 'got 7 events';
    @events ||= [] xx 7;
    is [Hitomi::StreamEventKind::start, ['span', Attrs.new(:class<baz>)]],
                                                       @events[0][0,1], 'o2[1]';
    is [Hitomi::StreamEventKind::start, ['b',    []]], @events[1][0,1], 'o2[2]';
    is [Hitomi::StreamEventKind::start, ['i',    []]], @events[2][0,1], 'o2[3]';
    is [Hitomi::StreamEventKind::text,  ['Foobar'  ]], @events[3][0,1], 'o2[4]';
    is [Hitomi::StreamEventKind::end,   ['i',      ]], @events[4][0,1], 'o2[5]';
    is [Hitomi::StreamEventKind::end,   ['b',      ]], @events[5][0,1], 'o2[6]';
    is [Hitomi::StreamEventKind::end,   ['span',   ]], @events[6][0,1], 'o2[7]';
}

{ # test_out_of_order_tags3
    my $text = '<span><b>Foobar</i>';
    my @events = (HTMLParser.new($text)).llist;
    is 5, +@events, 'got 5 events';
    @events ||= [] xx 5;
    is [Hitomi::StreamEventKind::start, ['span', []]], @events[0][0,1], 'o3[1]';
    is [Hitomi::StreamEventKind::start, ['b',    []]], @events[1][0,1], 'o3[2]';
    is [Hitomi::StreamEventKind::text,  ['Foobar'  ]], @events[2][0,1], 'o3[3]';
    is [Hitomi::StreamEventKind::end,   ['b',      ]], @events[3][0,1], 'o3[4]';
    is [Hitomi::StreamEventKind::end,   ['span',   ]], @events[4][0,1], 'o3[5]';
}

{ # test_hex_charref
    my $text = '<span>&#x27;</span>';
    my @events = (HTMLParser.new($text)).llist;
    is 3, +@events, 'got 3 events';
    @events ||= [] xx 3;
    is [Hitomi::StreamEventKind::start, ['span', []]], @events[0][0,1], 'hc[1]';
    is [Hitomi::StreamEventKind::text,  ["'"       ]], @events[1][0,1], 'hc[2]';
    is [Hitomi::StreamEventKind::end,   ['span'    ]], @events[2][0,1], 'hc[3]';
}
