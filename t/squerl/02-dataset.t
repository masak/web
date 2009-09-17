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

{
    ok Squerl::Dataset ~~ Positional, 'you can index into Squerl::Dataset';
}

{
    my $db = Squerl::Database.new( :quote_identifiers );
    ok $db.from('a').quote_identifiers,
       'should get quote_identifiers default from database I';
    $db = Squerl::Database.new( :!quote_identifiers );
    nok $db.from('a').quote_identifiers,
       'should get quote_identifiers default from database II';
}

{
    my $db = Squerl::Database.new( :identifier_input_method<upcase> );
    ok $db.from('a').identifier_input_method eq 'upcase',
        'should get identifier_input_method default from database I';
    $db = Squerl::Database.new( :identifier_input_method<downcase> );
    ok $db.from('a').identifier_input_method eq 'downcase',
        'should get identifier_input_method default from database II';
}

{
    my $db = Squerl::Database.new( :identifier_output_method<upcase> );
    ok $db.from('a').identifier_output_method eq 'upcase',
        'should get identifier_output_method default from database I';
    $db = Squerl::Database.new( :identifier_output_method<downcase> );
    ok $db.from('a').identifier_output_method eq 'downcase',
        'should get identifier_output_method default from database II';
}

$dataset = Squerl::Dataset.new('db');

{
    $dataset.quote_identifiers = True;
    is $dataset.literal('a'), '"a"',
       'setting quote_identifiers to True makes .literal quote identifiers';
    $dataset.quote_identifiers = False;
    is $dataset.literal('a'), 'a',
       'setting quote_identifiers to False makes .literal '
       ~ 'not quote identifiers';
}

{
    $dataset.identifier_input_method = 'upcase';
    is $dataset.literal('a'), 'A',
        'identifier_input_method changes literalization of identifiers I';
    $dataset.identifier_input_method = 'downcase';
    is $dataset.literal('A'), 'a',
        'identifier_input_method changes literalization of identifiers II';
    $dataset.identifier_input_method = 'reverse';
    is $dataset.literal('at_b'), 'b_ta',
        'identifier_input_method changes literalization of identifiers III';

    $dataset.identifier_input_method = 'uc';
    is $dataset.literal('a'), 'A',
        'identifier_input_method changes literalization of identifiers IV';
    $dataset.identifier_input_method = 'lc';
    is $dataset.literal('A'), 'a',
        'identifier_input_method changes literalization of identifiers V';
    $dataset.identifier_input_method = 'flip';
    is $dataset.literal('at_b'), 'b_ta',
        'identifier_input_method changes literalization of identifiers VI';
}

done_testing;
