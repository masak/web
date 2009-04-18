class Routes::Route;
has @.pattern;
has @.args;

has $.controller;
has $.action;
has Code $.code;

has %params;

# params
has $.slurp is rw = False;

method match (@chunks) {
    # RAKUDO: Whatever do not work as specified with zip operator, [perl #64474]
    # S03: "...short list may always be extended arbitrarily by putting C<*> 
    # after the final value, which replicates the final value as many times as necessary
    # so, imitation:

    my @tmp_pattern = @!pattern;
    
    if $!slurp and @!pattern < @chunks and @!pattern[*-1] ~~ Whatever {
        @tmp_pattern.push: * xx @chunks - @!pattern; 
    } else { 
        return False if @chunks != @!pattern;
    }

    #say 'pattern:' ~ @tmp_pattern.perl;

    for @chunks Z @tmp_pattern -> $chunk, Object $rule {
        if ~$chunk ~~ ($rule ~~ Pair ?? $rule.value !! $rule) {
            given $rule {
                # RAKUDO: /./ ~~ Regex is false, but /./ ~~ Code is true  
                when Code | Whatever { @!args.push($/ || $chunk) } # should be Regex | Whatever
                when Pair            { %!params{$rule.key}  = $/ || $chunk }
            }
        }
        else {
            self.clear;
            return False;
        }
    }
    return True;
}

method apply {
    # RAKUDO: die with FixedIntegerArray: index out of bounds! on test 01/3
    #$!code(| @!args, | %!params );
    # workaround:
    
    $!action = %!params<action> if %!params<action>;
    $!controller = %!params<controller> if %!params<controller>;

    if $!controller and $!action {
        $!code(| @!args, action => $.action, controller => $.controller  );
    } elsif $!action {
        $!code(| @!args, action => $.action );
    } elsif $!controller {
        $!code(| @!args, controller => $.controller );
    } else {
        #say 'call: (|' ~ @!args.perl ~ ')';
        $!code(| @!args );
    }
}

method is_complete {
    return ?( @!pattern && $!code );
}

method clear {
    @!args = ();
    $!controller = undef;
    $!action = undef;
    %!params = ();
}

# vim:ft=perl6
