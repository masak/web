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
        $!compiled = 'my sub print(*@args) { $*result ~= $_ for @args };'
                     ~ $!compiled;
        return;
    }

    method emit-hunk(Int $i) {
        $*result ~= @!hunks[$i][0];
    }

    method serialize(*%attrs) {
        my $*result = '';
        eval $!compiled;
        return $*result;
    }
}
