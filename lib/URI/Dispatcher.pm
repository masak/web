use v6;

class URI::Dispatcher {
    has @.rules;

    method new(*@rules) {
        self.bless(self.CREATE, :@rules);
    }

    sub binds(Str $matcher, Str $url) {
        if $matcher ~~ / ':' \w+ / {
            my $remainder = $matcher;
            my $index = 0;
            my %names;
            while $remainder ~~ / ':' (\w+) / {
                my $key = $0;
                my $constant_part = $remainder.substr(0, $/.from);
                return False
                    unless $url.substr($index, $/.from) eq $constant_part;
                $remainder = $remainder.substr($/.to);
                $index += $/.from;
                $url.substr($index) ~~ / <-[/]>+ /;
                my $value = ~$/;
                $index += $value.chars;
                %names{$key} = $value;
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
