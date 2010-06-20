class Ratel {
    has $!source;
    has $!compiled;
    has @!hunks;
    has %.transforms is rw;

    submethod BUILD(:%transforms, :$source) {
        # XXX Needs to be re-thought to allow wrapping the contents of the
        # unquote, use parameterized delims, etc...
        %!transforms = %transforms;
        %!transforms{'='} = -> $a {"print $a"};
        %!transforms{'!'} = -> $a {'print %attrs<' ~ $a ~ '>'};
        $.source($source);
    }
    multi method load(Str $filename) {
        $.source(slurp($filename));
    }

    multi method source() {
        return $!source;
    }
    multi method source(Str $text) {
        my $index = 0;
        $!source = $text;
        my $source = "%]{$text}[%";
        for %!transforms.kv -> $k, $v {
            $source.=subst((eval "/'[%$k' (.*?) '%]'/"), -> $match {'[%' ~ $v($match[0]) ~ '%]'}, :g);
        }
        @!hunks = $source.comb(/'%]' (.*?) '[%'/);
        $!compiled
            = $source.subst(/(['%]' | ^ ] .*? [ $ | '[%' ])/,
                            {";\$.emit-hunk({$index++});"},
                            :g);
        $!compiled = $!compiled;
        return;
    }

    method emit-hunk(Int $i) {
        $.emit(@!hunks[$i][0]);
    }
    method emit($m) {
        $*result ~= $m;
    }

    method render(*%attrs) {
        my $*result = '';
        my $obj = self;
        # XXX Needs cleanup...
        my $*OUT = (class {
                method say(*@args) {
                    $obj.emit($_) for (@args, "\n");
                }
                method print(*@args) {
                    $obj.emit($_) for @args;
                }
            }).new();;
        eval $!compiled;
        return $*result;
    }
}
