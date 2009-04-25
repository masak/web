use v6;

use Test;
use Hitomi;

my @correct-xml =
    '<a/>',
    '<html />',
    '<html></html>',
;

my @incorrect-xml =
    ''
;

plan @correct-xml + @incorrect-xml;

ok  Hitomi::XML.parse($_) for @correct-xml;
nok Hitomi::XML.parse($_) for @incorrect-xml;
