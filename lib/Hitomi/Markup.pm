use Hitomi::XMLParser;

class Hitomi::Template {
    has $!source;
    has $!filepath;
    has $!filename;
    has $!loader;
    has $!encoding;
    has $!lookup;
    has $!allow_exec;
    has $!stream;

    submethod BUILD(:$source, :$filepath, :$filename, :$loader,
                    :$encoding, :$lookup, :$allow_exec) {

        $!source     = $source;
        $!filepath   = $filepath;
        $!filename   = $filename;
        $!loader     = $loader;
        $!encoding   = $encoding;
        $!loader     = $loader;
        $!allow_exec = $allow_exec;

        $!filepath //= $!filename;

        $!stream = self._parse($!source, $!encoding);
    }

    method new($source, $filepath?, $filename?, $loader?,
               $encoding?, $lookup = 'strict', $allow_exec = True) {
        self.bless(*,
                   :$source, :$filepath, :$filename, :$loader,
                   :$encoding, :$lookup, :$allow_exec);
    }

    method _parse($source, $encoding) {
        ...
    }

    method generate(*%nameds, *@pairs) {
        return $!stream;
    }
}

class Hitomi::MarkupTemplate is Hitomi::Template {
    submethod BUILD(:$!source, :$!filepath, :$!filename, :$!loader,
                    :$!encoding, :$!lookup, :$!allow_exec) {
    }

    method _parse($source is copy, $encoding) {
        if $source !~~ Hitomi::Stream {
            $source = Hitomi::XMLParser.new($source, $!filename, $encoding);
        }

        my @stream;

        for $source.llist -> @event {
            my ($kind, $data, $pos) = @event;

            @stream.push( [$kind, $data, $pos] );
        }

        return Hitomi::Stream.new(@stream);
    }
}

class Hitomi::Markup {
    method new($text) {
        return self.bless(*, :$text);
    }
}
