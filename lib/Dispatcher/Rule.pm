class Dispatcher::Rule;
has @.pattern;
has @.args;

has Str $.controller is rw;
has Str $.action     is rw;
has Code $.code;

# params
has $.slurp is rw = False;

method match (@chunks) {
    return False if ! $.slurp and @chunks != @!pattern;

    # RAKUDO: Whatever do not work as specified with zip operator, [perl #64474]
    # S03: "...short list may always be extended arbitrarily by putting C<*> 
    # after the final value, which replicates the final value as many times as necessary
    # so, I should make workaround if nobody fix it first

    for @chunks Z @!pattern-> $chunk, Object $rule {
        if ~$chunk ~~ ($rule ~~ Pair ?? $rule.value !! $rule) {
            given $rule {
                # RAKUDO: /./ ~~ Regex us false, but /./ ~~ Code is true  
                when Code | Whatever { @!args.push($/ || $chunk) } # should be Regex | Whatever
                when Pair            { self."{ $rule.key }" = (~$/ || ~$chunk) }
                when Array           { ... }
                when Range           { ... }
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
    #$!code(| @!args, controller => $.controller, action => $.action );
    # workaround:
    if $!controller and $!action {
        $!code(| @!args,action => $.action, controller => $.controller  );
    } elsif $!action {
        $!code(| @!args, action => $.action );
    } elsif $!controller {
        $!code(| @!args, controller => $.controller );
    } else {
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
}

# vim:ft=perl6
