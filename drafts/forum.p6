use Forest;

my $f = Forest.new;

for $f {
    .handle([''], 'GET');
    .handle(['topic'], 'GET');
    .handle(['topic'], 'POST');
    .handle(['topic'], 'POST', {title => 'foo', body => 'text'});
    .handle(['topic', '1'], 'GET');
    .handle(['topic', '1', 'comment'], 'GET');
}

# vim: ft=perl6
