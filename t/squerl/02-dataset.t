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

    $d = Squerl::Dataset.new($db);
    is $d.db, $db, 'attribtue .db was properly set';
    ok $d.opts ~~ Hash, 'attribute .opts is a hash even when not set';
    is_deeply $d.opts, {}, 'attribute .opts is empty';
}

{
    my $d1 = $dataset.clone( :from( ['test'] ) );
    is $d1.WHAT, $dataset.WHAT, 'clone has the same class as original';
    ok $d1 !=== $dataset, 'clone is distinct from original';
    ok $d1.db === $dataset.db, 'clone has the same .db attribute';
    is_deeply $d1.opts<from>, ['test'],
              'the attribute passed with the .clone method is there';
    ok !$dataset.opts.exists('from'), 'the original is unchanged';

    my $d2 = $d1.clone( :order( ['name'] ) );
    is $d2.WHAT, $dataset.WHAT, 'clone of clone has the class of original';
    ok $d2 !=== $d1, 'clone of clone is distinct from clone';
    ok $d2 !=== $dataset, 'clone of clone is distinct from original';
    ok $d2.db === $dataset.db, 'clone of clone has the same .db attribute';
    is_deeply $d2.opts<from>, ['test'],
              'the attribute from the first clone is preserved in the second';
    is_deeply $d2.opts<order>, ['name'],
              'the attribute passed with the .clone method is there';
    ok !$d1.opts.exists('order'), 'the original clone is unchanged';
}

done_testing;
