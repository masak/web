class Ratel {
    has $.source;
    has $.compiled;
    has @.hunks;
    method load(Str $filename) {
        $.compile(slurp($filename));
    }
    method compile(Str $text) {
        my $index = 0;
        $!source = $text;
        my $source = "%]$text[%";
        @!hunks = $source.comb(/'%]' (.*?) '[%'/);
        $!compiled = $source.subst(/(['%]' | ^ ] .*? [ $ | '[%' ])/, {";\$.emit-hunk({$index++});"}, :g);
    }
    method emit-hunk(Int $i) {
        print @.hunks[$i][0];
    }
    method do(*%attrs) {
        eval $.compiled;
    }
}
