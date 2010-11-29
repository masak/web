use v6;

# Copyright (C) 2006 Edgewall Software
# All rights reserved.
#
# This software is licensed as described in the file licences/genshi/COPYING,
# which you should have received as part of this distribution. The terms
# are also available at http://genshi.edgewall.org/wiki/License.

use Test;
plan 22;

use Hitomi::Stream;
use Hitomi::Markup;
use Hitomi::Input;

constant Stream = Hitomi::Stream;
constant MarkupTemplate
                = Hitomi::MarkupTemplate;
constant Markup = Hitomi::Markup;

## MarkupTemplateTestCase - Tests for markup template processing.

{ # test_parse_string
    my $string = '<root> ${$var} $var</root>';
    my $tmpl = MarkupTemplate.new($string);
    is '<root> 42 42</root>',
       ~$tmpl.generate(:var(42)),
       'markup from a string';
}

skip(1);
# skip: unknown error in MarkupTemplate.new($stream)
##{ # test_parse_stream
##    my Stream $stream = XML('<root> ${$var} $var</root>');
##    my $tmpl = MarkupTemplate.new($stream);
##    is '<root> 42 42</root>', ~$tmpl.generate(:var(42)), 'markup from a stream';
##}

skip(1);
# skip: unknown error in MarkupTemplate.new($stream)
##{ # test_pickle
##    # Not sure how we will want to do this.
##    my Stream $stream = XML('<root>$var</root>');
##    my $tmpl = MarkupTemplate.new($stream);
##    my $buf = $tmpl.perl;
##    my $unpickled = eval($buf);
##    is '<root>42</root>', ~$unpickled.?generate(:var(42)),
##       'template survives pickling';
##}

{ # test_interpolate_mixed3
    my $tmpl = MarkupTemplate.new('<root> ${$var} $var</root>');
    is '<root> 42 42</root>', ~$tmpl.generate(:var(42)), 'mixed interpolation';
}

todo('not implemented yet', 2);
{ # test_interpolate_leading_trailing_space
    my $tmpl = MarkupTemplate.new('<root>${    $foo    }</root>');
    is '<root>bar</root>', ~$tmpl.generate(:foo<bar>), 'leading/trailing space';
}

{ # test_interpolate_multiline
    my $tmpl = MarkupTemplate.new(q[<root>${(
          bar => 'baz'
        ).hash{$foo}}</root>]);
    is '<root>baz</root>', ~$tmpl.generate(:foo<bar>), 'interpolate multiline';
}

skip(1);
##{ # test_interpolate_non_string_attrs
##    my $tmpl = MarkupTemplate.new('<root attr="${1}"/>');
##    is '<root attr="1"/>', ~$tmpl.generate(), 'interpolate non-string attrs';
##}

todo('not implemented', 1);
{ # test_interpolate_list_result
    my $tmpl = MarkupTemplate.new('<root>@foo</root>');
    is '<root>buzz</root>', ~$tmpl.generate('@foo' => ['buzz']),
       'interpolate lists';
}

skip(1);
##{ # test_empty_attr
##    my $tmpl = MarkupTemplate.new('<root attr=""/>');
##    is '<root attr=""/>', ~$tmpl.generate(), 'empty attribute';
##}

skip(1);
##{ # test_empty_attr_interpolated
##    my $tmpl = MarkupTemplate.new('<root attr="$attr"/>');
##    is '<root attr=""/>', ~$tmpl.generate(:attr<>), 'empty attr, interpolated';
##}

todo('not implemented', 3);
{ # test_bad_directive_error
    my $xml
        = '<p xmlns:pl="http://github.com/masak/hitomi" pl:do="nothing" />';
    my $died = True;
    try {
        my $tmpl = MarkupTemplate.new($xml, :filename<test.html>);
        $died = False;
    }
    # RAKUDO: When we have CATCH, we will want to check the error type here
    ok $died, 'error on bad directive';
    # self.assertEqual('test.html', e.filename)
    # self.assertEqual(1, e.lineno)
}

{ # test_directive_value_syntax_error
    my $xml = q[<p xmlns:pl="http://github.com/masak/hitomi" pl:if="bar'" />];
    my $died = True;
    try {
        my $tmpl = MarkupTemplate.new($xml, :filename<test.html>).generate();
        $died = False;
    }
    # RAKUDO: When we have CATCH, we will want to check the error type here
    ok $died, 'error on bad directive';
    # self.assertEqual('test.html', e.filename)
    # self.assertEqual(1, e.lineno)
}

{ # test_expression_syntax_error
    my $xml = q[<p>
          Foo <em>${bar"}</em>
        </p>];
    my $died = True;
    try {
        my $tmpl = MarkupTemplate.new($xml, :filename<test.html>);
        $died = False;
    }
    # RAKUDO: When we have CATCH, we will want to check the error type here
    ok $died, 'template syntax error';
    # self.assertEqual('test.html', e.filename)
    # self.assertEqual(2, e.lineno)
}

{ # test_expression_syntax_error_multi_line
    my $xml = q[<p><em></em>

 ${bar"}

        </p>];
    my $died = True;
    try {
        my $tmpl = MarkupTemplate.new($xml, :filename<test.html>);
        $died = False;
    }
    # RAKUDO: When we have CATCH, we will want to check the error type here
    ok $died, 'template syntax error';
    # self.assertEqual('test.html', e.filename)
    # self.assertEqual(3, e.lineno)
}

skip(1);
##{ # test_markup_noescape
##    # Verify that outputting context data that is a `Markup` instance is not
##    # escaped.
##    my $tmpl = MarkupTemplate.new(
##        '<div xmlns:pl="http://github.com/masak/hitomi">
##           $myvar
##         </div>');
##    is  '<div>
##           <b>foo</b>
##         </div>', ~$tmpl.generate(:myvar(Markup.new('<b>foo</b>'))),
##         'no escaping of Markup variables';
##}

skip(1);
##{ # test_text_noescape_quotes
##    # Verify that outputting context data in text nodes doesn't escape
##    # quotes.
##    my $tmpl = MarkupTemplate.new(
##        '<div xmlns:pl="http://github.com/masak/hitomi">
##           $myvar
##         </div>');
##    is  '<div>
##           "foo"
##         </div>', ~$tmpl.generate(:myvar<"foo">),
##        'no escaping of quotes in text';
##}

skip(1);
##{ # test_attr_escape_quotes
##    # Verify that outputting context data in attribtes escapes quotes.
##    my $tmpl = MarkupTemplate.new(
##        '<div xmlns:pl="http://github.com/masak/hitomi">
##           <elem class="$myvar"/>
##         </div>');
##    is  '<div>
##           <elem class="&#34;foo&#34;"/>
##         </div>', ~$tmpl.generate(:myvar<"foo">),
##        'escaping of quotes in attrs';
##}

skip(1);
##{ # test_directive_element
##    my $tmpl = MarkupTemplate.new(
##        '<div xmlns:pl="http://github.com/masak/hitomi">
##           <pl:if test="myvar">bar</pl:if>
##         </div>');
##    is  '<div>
##           bar
##         </div>', ~$tmpl.generate(:myvar<"foo">), 'directive';
##}

skip(1);
##{ # test_normal_comment
##    my $tmpl = MarkupTemplate.new(
##        '<div xmlns:pl="http://github.com/masak/hitomi">
##           <!-- foo bar -->
##         </div>');
##    is  '<div>
##           <!-- foo bar -->
##         </div>', ~$tmpl.generate(), 'normal comment';
##}

skip(1);
##{ # test_template_comment
##    my $tmpl = MarkupTemplate.new(
##        '<div xmlns:pl="http://github.com/masak/hitomi">
##           <!-- !foo -->
##           <!--!bar-->
##         </div>');
##    is  '<div>
##         </div>', ~$tmpl.generate(), 'template comment';
##}

skip(1);
##{ # test_parse_with_same_namespace_nested
##    my $tmpl = MarkupTemplate.new(
##        '<div xmlns:pl="http://github.com/masak/hitomi">
##           <span xmlns:pl="http://github.com/masak/hitomi">
##           </span>
##         </div>');
##    is  '<div>
##           <span>
##           </span>
##         </div>', ~$tmpl.generate(), 'nested namespace';
##}

skip(1);
##{ # test_latin1_encoded_with_xmldecl
##    my $tmpl = MarkupTemplate.new(
##        qq[<?xml version="1.0" encoding="iso-8859-1" ?>
##        <div xmlns:pl="http://github.com/masak/hitomi">
##          \xf6
##        </div>].encode('UTF-8').decode('iso-8859-1'), :encoding<iso-8859-1>);
##    is qq[<?xml version="1.0" encoding="iso-8859-1"?>\n<div>
##          \xf6
##        </div>], ~$tmpl.generate(), 'latin1 encoded with xmldecl';
##}
