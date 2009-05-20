use v6;

use Test;
use Hitomi;

my @valid-xml =
    '<a/>',
    '<html />',
    '<html></html>',
;

my @invalid-xml =
    '',
    '<',
    '<a',
    '<a>',
    '<a><b></a></b>',
;

plan @valid-xml + @invalid-xml;

ok  Hitomi::XML.parse($_), "$_ is valid"   for @valid-xml;
nok Hitomi::XML.parse($_), "$_ is invalid" for @invalid-xml;
