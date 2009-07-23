use v6;

use Hitomi::Stream;
use Hitomi::XMLParser;

class ParseError {
}

sub XML($text) {
    return Hitomi::Stream.new(@(Hitomi::XMLParser.new($text)));
}
