class Forest;

has %.resources;

multi method handle (@chunks, $method, %data?, @stash?) {
    my $res_name;
    my @args;
    my $action = $method;
    @chunks.shift if @chunks[0] eq '';
    given @chunks.elems {
        when 1 {
            if @chunks[0] ~~ Str {
                $res_name = @chunks[0];
            }
        }
        when 2 {
            $res_name = @chunks.shift;
            @args = @chunks;
        }
        when 3..4  {
            $res_name = @chunks.shift;
            @args = @chunks;
            $action = 'Link';
        }
        default {
            $res_name = 'Root';
            @args = @chunks if @chunks;
        }
    } 

    unless %.resources{$res_name} {
        $res_name = 'Controller::' ~ $res_name.capitalize; 
        use $res_name;
        %.resources{$res_name} = "$res_name".new unless $!;
    }

    @args.push(@stash) if @stash;
    @args.push(\%data) if %data;

    say "$action $res_name " ~ @args.perl;
    
    # RAKUDO: multiple return does not work properly [perl #63912]
    my ($rest, $stash) = %!resources{$res_name}."$action"(| @args); 
   
    # (| @args).perl.say;

    say 'R:' ~ $rest.perl;
    say 'S:' ~ $stash.perl;
    my @re = $rest.list;
    my @st = $stash.list;
    
    if $action eq 'Link'{
        self.handle(@re, $method, %data, @st);
    }
}

# vim: ft=perl6
