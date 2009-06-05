class Routes::Route;
has @.pattern;

has Code $.code;

has @.positional-args;
has %.named-args;

has $.controller  = 'Root';
has $.action      = 'index';

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
                when Regex | Whatever { @!positional-args.push($/ || $chunk) }
                when Pair             { %!named-args{$rule.key}  = $/ || $chunk }
            }
        }
        else {
            self.clear;
            return False;
        }
    }
    return True;
}

method apply ($env is rw) {
    given %!named-args {
        .<controller> //= $!controller;
        .<action> //= $!action;

        # RAKUDO: rt?
        #.<controller action>.=map: *.lc.ucfirst;
        .<controller action>.=map: *.lc;
        .<controller action>.=map: *.ucfirst;

        # See POST param first because HTML4 does not support PUT and DELETE
        #.<method> = $env ~~ Web::Request ?? ($env.POST<request_method> || $env<request_method>) !! 'GET';
        #.<method> .= uc;
    
        #.<env> := $env;
        #.<controllers> := %*controllers; # hm
    }

    # add body as last positional args if it true, this make MMD easier
    @!positional-args.push($env<body>) if $env<body>;

    say 'call: (|' ~ @!positional-args ~  ', |' ~ %!named-args.perl ~ ')';

    # Rakudo bug? It is die here with:
    # ok 3 - .add adds only complete Route objects
    # call: (|, |{"controller" => "Root", "action" => "Index"})
    # FixedIntegerArray: index out of bounds!
    # in method Routes::Route::apply (t/routes/01-basics.t:14)
    # called from method Routes::dispatch (./lib/Routes.pm:39)
    # called from method Routes::dispatch (./lib/Routes.pm:30)
    # called from Main (t/routes/01-basics.t:19)

    $!code(| @!positional-args, | %!named-args );
}

method is_complete {
    return ?( @!pattern && $!code );
}

method clear {
    @!positional-args = ();
    %!named-args = ();
}

# vim:ft=perl6
