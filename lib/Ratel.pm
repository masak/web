class Ratel {
    has $.source;
    has $!compiled;
    has @!hunks;

    method load(Str $filename) {
        $.compile(slurp($filename));
    }

    method compile(Str $text) {
        my $index = 0;
        $!source = $text;
        my $source = "%]$text[%";
        $source.=subst('[%=', '[% print ', :g);
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
