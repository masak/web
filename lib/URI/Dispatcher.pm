use v6;

class URI::Dispatcher {
    has @.rules;

    method new(*@rules) {
        self.bless(self.CREATE, :@rules);
    }

    sub binds(Str $matcher, Str $url) {
        my $params_regex = / [':' (\w+) || ('**') || ('*')] /;

        if $matcher ~~ $params_regex {
            my $remainder = $matcher;
            my $index = 0;
            my %names = splat => [];
            while $remainder ~~ $params_regex {
                my $key = $0;
                my $constant_part = $remainder.substr(0, $/.from);
                return False
                    unless $url.substr($index, $/.from) eq $constant_part;
                $remainder = $remainder.substr($/.to);
                $index += $/.from;
                my $value;
                if $key eq '**' {
                    my $next_constant_part = $remainder;
                    if $remainder ~~ $params_regex {
                        $next_constant_part = $remainder.substr(0, $/.from);
                    }
                    # RAKUDO: Wanted to use .rindex here, but got non-isolable
                    #         confusing results when doing so.
                    my $next_index = $url.index($next_constant_part, $index);
                    return False
                        unless defined $next_index;
                    $value
                        = $url.substr($index, $next_index - $index);
                }
                else {
                    $url.substr($index) ~~ / <-[/]>+ /;
                    $value = ~$/;
                }
                $index += $value.chars;
                if $key eq '*' | '**' {
                    %names<splat>.push($value);
                }
                else {
                    %names{$key} = $value;
                }
            }
            if $url.substr($index) eq $remainder {
                return { url => $url, %names };
            }
        }
        elsif $matcher eq $url {
            return { url => $url };
        }

        return False;
    }

    method dispatch($url) {
        for @.rules -> $rule {
            my ($matcher, &callback) = $rule.key, $rule.value;

            if binds($matcher, $url) -> %bindinfo {
                callback(%bindinfo);
                return True;
            }

            return False;
        }
    }
}
