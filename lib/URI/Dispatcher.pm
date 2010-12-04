use v6;

class URI::Dispatcher {
    has @.rules;

    method new(*@rules) {
        self.bless(self.CREATE, :@rules);
    }

    method dispatch($url) {
        for @.rules -> $rule {
            my ($matcher, &callback) = $rule.key, $rule.value;

            if $matcher eq $url {
                callback();
                return True;
            }

            return False;
        }
    }
}
