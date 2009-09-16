use v6;
use Test;

use Squerl;

my $dataset = Squerl::Dataset.new('db');

{
    my $db = 'db';
    my %opts = :from<test>;
    my $d = Squerl::Dataset.new($db, |%opts);
    is $d.db, $db, 'attribtue .db was properly set';
    is_deeply $d.opts, %opts, 'attribute .opts was properly set';
}
