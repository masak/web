use v6;
use Test;

use Ratel;
plan 2;

my $template = q|<html>
<title>[%! title %]</title>
<ul>
[% for 1..10 { %]
<li>item [%= $_ %]</li>
[% } %]
</ul>
</html>|;

my Ratel $r .= new(:source($template));
my $text = $r.render(:title('OMG HAI GUYS!!'));

ok( $text ~~ /'item 2'/, 'Basic rendering' );
ok( $text ~~ /'OMG HAI'/, 'Attribute interpolation' );
