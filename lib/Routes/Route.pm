class Routes::Route;
has @.pattern;
has @.args;
has %.args;

has $.controller;
has $.action;
has Code $.code;

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
                when Pair            { %!args{$rule.key}  = $/ || $chunk }
            }
        }
        else {
            self.clear;
            return False;
        }
    }
    return True;
}

method apply (%param) {
    # RAKUDO: This is set %!args<action> and <controller> as undef, because of rakudobug
    # $!action = %!args<action> if %!args<action>;
    # $!controller = %!args<controller> if %!args<controller>;
    # and call block with named params, when block do not have %_ 
    # in signature fall with another rakudobug [perl #64844] 

    #say 'call: (|' ~ @!args.perl ~  ', |' ~ %!args.perl ~')';
    
    # mb we should use differnet containers for params and args fetched from path. 
    my %named_args = %!args.pairs, %param.pairs;
    $!code(| @!args, | %named_args );
}

method is_complete {
    return ?( @!pattern && $!code );
}

method clear {
    @!args = ();
    %!args = ();
    $!controller = undef;
    $!action = undef;
}

# vim:ft=perl6
