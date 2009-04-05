class Dispatcher::Rule;
has @.pattern;
has @.args;

has Str $.controller is rw;
has Str $.action     is rw;
has Code $.code;

method match (@chunks) {
    return False if @chunks != @!pattern;

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
