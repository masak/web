use Forest;

my $f = Forest.new;

for $f {
    .handle([''], 'GET');
    .handle(['topic'], 'GET');
    .handle(['topic'], 'POST');
    .handle(['topic'], 'POST', {title => 'foo', body => 'text'});
    .handle(['topic', '1'], 'GET');
    .handle(['topic', '2', 'comment'], 'GET');
    .handle(['topic', '3', 'comment', '1'], 'GET');
}

# vim: ft=perl6
