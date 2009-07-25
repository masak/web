use Hitomi::Stream;
use Hitomi::XMLParser;
use Hitomi::Interpolation;

class Hitomi::Context {
    # I see from the Genshi source that %!vars will eventually be replaced by
    # @!frames. This suffices for now.
    has %!vars;

    method new(*%nameds, *@pairs) {
        my %vars = %nameds;
        for @pairs {
            %vars{.key} = .value;
        }
        return self.bless(*, :%vars);
    }

    method get($thing is copy) {
        if $thing ~~ /^ '$'/ {
            $thing .= substr(1);
        }
        %!vars{$thing};
    }
}

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
        my $context = Hitomi::Context.new(|%nameds, |@pairs);
        return self._flatten($!stream, $context);
    }

    method _flatten($stream, $context) {
        my @newstream = gather for $stream.llist -> $event {
            my ($kind, $data, $pos) = @($event);
            if ($kind ~~ Hitomi::StreamEventKind::expr) {
                take [Hitomi::StreamEventKind::text,
                      self._eval($data, $context),
                      $pos];
            }
            else {
                take [$kind, $data, $pos];
            }
        };
        return Hitomi::Stream.new(@newstream);
    }

    method _eval($data, $context) {
        # Well, this works for expressions which consist of one variable
        # and nothing more. Will expand later.
        $context.get($data);
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

            if $kind ~~ Hitomi::StreamEventKind::text {
                @stream.push:
                    interpolate($data, $!filepath, $pos[1], $pos[2], $!lookup);
            }
            else {
                @stream.push( [$kind, $data, $pos] );
            }
        }

        return Hitomi::Stream.new(@stream);
    }
}

class Hitomi::Markup {
    method new($text) {
        return self.bless(*, :$text);
    }
}
