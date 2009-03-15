class Forest;

has %.resources;

multi method handle (@chunks, $method, %data?) {
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
        when 3  {
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
        $res_name = 'Res::' ~ $res_name.capitalize; 
        use $res_name;
        %.resources{$res_name} = "$res_name".new;
    }

    @args.push(\%data) if %data;
    my @back = $.resources{$res_name}."$action"(| @args);

    if @back.shift eq 'next' {
        self.handle(@back, $method, %data);
    }
}

# vim: ft=perl6
