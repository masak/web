use v6;
use Test;

use Squerl;

my $dataset = Squerl::Dataset.new('db');

# RAKUDO: There are plenty of unnecessary semicolons at the end of blocks
#         in this file, due to [perl #69438]

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
};

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
};

{
    ok Squerl::Dataset ~~ Positional, 'you can index into Squerl::Dataset';
};

{
    my $db = Squerl::Database.new( :quote_identifiers );
    ok $db.from('a').quote_identifiers,
       'should get quote_identifiers default from database I';
    $db = Squerl::Database.new( :!quote_identifiers );
    nok $db.from('a').quote_identifiers,
       'should get quote_identifiers default from database II';
};

{
    my $db = Squerl::Database.new( :identifier_input_method<upcase> );
    ok $db.from('a').identifier_input_method eq 'upcase',
        'should get identifier_input_method default from database I';
    $db = Squerl::Database.new( :identifier_input_method<downcase> );
    ok $db.from('a').identifier_input_method eq 'downcase',
        'should get identifier_input_method default from database II';
};

{
    my $db = Squerl::Database.new( :identifier_output_method<upcase> );
    ok $db.from('a').identifier_output_method eq 'upcase',
        'should get identifier_output_method default from database I';
    $db = Squerl::Database.new( :identifier_output_method<downcase> );
    ok $db.from('a').identifier_output_method eq 'downcase',
        'should get identifier_output_method default from database II';
};

$dataset = Squerl::Dataset.new('db');

{
    $dataset.quote_identifiers = True;
    is $dataset.literal(ident('a')), '"a"',
       'setting quote_identifiers to True makes .literal quote identifiers';
    $dataset.quote_identifiers = False;
    is $dataset.literal(ident('a')), 'a',
       'setting quote_identifiers to False makes .literal '
       ~ 'not quote identifiers';
};

{
    $dataset.identifier_input_method = 'upcase';
    is $dataset.literal(ident('a')), 'A',
        'identifier_input_method changes literalization of identifiers I';
    $dataset.identifier_input_method = 'downcase';
    is $dataset.literal(ident('A')), 'a',
        'identifier_input_method changes literalization of identifiers II';
    $dataset.identifier_input_method = 'reverse';
    is $dataset.literal(ident('at_b')), 'b_ta',
        'identifier_input_method changes literalization of identifiers III';

    $dataset.identifier_input_method = 'uc';
    is $dataset.literal(ident('a')), 'A',
        'identifier_input_method changes literalization of identifiers IV';
    $dataset.identifier_input_method = 'lc';
    is $dataset.literal(ident('A')), 'a',
        'identifier_input_method changes literalization of identifiers V';
    $dataset.identifier_input_method = 'flip';
    is $dataset.literal(ident('at_b')), 'b_ta',
        'identifier_input_method changes literalization of identifiers VI';
};

{
    is $dataset.output_identifier('at_b_C'), 'at_b_C',
        'identifier_output_method changes identifiers returned from the db I';

    $dataset.identifier_output_method = 'upcase';
    is $dataset.output_identifier('at_b_C'), 'AT_B_C',
        'identifier_output_method changes identifiers returned from the db II';
    $dataset.identifier_output_method = 'downcase';
    is $dataset.output_identifier('at_b_C'), 'at_b_c',
        'identifier_output_method changes identifiers returned from the db III';
    $dataset.identifier_output_method = 'reverse';
    is $dataset.output_identifier('at_b_C'), 'C_b_ta',
        'identifier_output_method changes identifiers returned from the db IV';

    $dataset.identifier_output_method = 'uc';
    is $dataset.output_identifier('at_b_C'), 'AT_B_C',
        'identifier_output_method changes identifiers returned from the db V';
    $dataset.identifier_output_method = 'lc';
    is $dataset.output_identifier('at_b_C'), 'at_b_c',
        'identifier_output_method changes identifiers returned from the db VI';
    $dataset.identifier_output_method = 'flip';
    is $dataset.output_identifier('at_b_C'), 'C_b_ta',
        'identifier_output_method changes identifiers returned from the db VII';
};

$dataset = Squerl::Dataset.new(undef).from('items');

{
    $dataset.row_proc = { $^r };
    my $clone = $dataset.clone;

    ok $clone !=== $dataset, 'the clone is not the original';
    is $clone.WHAT, $dataset.WHAT, 'clone has the same type as original';
    is_deeply $clone.opts, $dataset.opts, 'opts attributes are equivalent';
    ok $clone.row_proc === $dataset.row_proc, 'row_proc attributes equal';
};

{
    my $clone = $dataset.clone;

    ok $clone.opts !=== $dataset.opts, 'cloning deep-copies .opts';
    $dataset.=filter( 'a' => 'b' );
    ok !$clone.opts.exists('filter'),
              'changing original.opts leaves clone.opts unchanged';
};

{
    my $clone = $dataset.clone;

    is $clone.WHAT, $dataset.WHAT, 'should return a clone self I';
    is $clone.db, $dataset.db, 'should return a clone self II';
    is_deeply $clone.opts, $dataset.opts, 'should return a clone self III';
};

$dataset = Squerl::Dataset.new(undef).from('items');

{
    my $clone = $dataset.clone( one => 2 );

    is_deeply $clone.opts, { one => 2, from => 'items' },
        'should merge the specified options';
};

{
    my $clone = $dataset.clone( :from(['other']) );

    is_deeply $clone.opts, { :from(['other']) },
        'should overwrite existing options';
};

{
    my $clone = $dataset.clone( :from(['other']) );

    is_deeply $dataset.opts<from>, 'items', 'original .opts<from> unharmed';
    is_deeply $clone.opts<from>, ['other'], 'cloned .opts<from> changed'
};

{
    # TODO: Can't realisticly do this one yet.

    # m = Module.new do
    #   def __xyz__; "xyz"; end
    # end
    # @dataset.extend(m)
    # @dataset.clone({}).should respond_to(:__xyz__)
};

$dataset = Squerl::Dataset.new(undef).from('test');

is $dataset.select_sql, 'SELECT * FROM test', 'format a select statement';
is $dataset.delete_sql, 'DELETE FROM test', 'format a delete statement';
is $dataset.truncate_sql, 'TRUNCATE TABLE test', 'format a truncate statement';
is $dataset.insert_sql, 'INSERT INTO test DEFAULT VALUES',
    'format an insert statement with default values';

{
    my $sql = $dataset.insert_sql(:name<wxyz>, :price(342));
    ok $sql eq q[INSERT INTO test (name, price) VALUES ('wxyz', 342)]
             | q[INSERT INTO test (price, name) VALUES (342, 'wxyz')],
        'format an insert statement with hash';
    is $dataset.insert_sql({}), 'INSERT INTO test DEFAULT VALUES',
        'empty hash gives an insert statement with default values';
};

{
    my $sql = $dataset.insert_sql( 'name' => 'wxyz', 'price' => 342 );
    ok $sql eq q[INSERT INTO test (name, price) VALUES ('wxyz', 342)]
             | q[INSERT INTO test (price, name) VALUES (342, 'wxyz')],
        'format an insert statement with string keys';
};

role R1 { method values { 'a' => 1; } }
role R2 { method values { {} } };

{
    my $v = Object.new but R1;
    is $dataset.insert_sql($v), 'INSERT INTO test (a) VALUES (1)',
        'format an insert statement with an object that .can("values") I';

    $v = Object.new but R2;
    is $dataset.insert_sql($v), 'INSERT INTO test DEFAULT VALUES',
        'format an insert statement with an object that .can("values") II';
};

{
    is $dataset.insert_sql(123), 'INSERT INTO test VALUES (123)',
        'format an insert statement with an arbitrary value';
};

{
    my $sub = Squerl::Dataset.new('').from('something').filter('x' => 2);
    is $dataset.insert_sql($sub),
       'INSERT INTO test SELECT * FROM something WHERE (x = 2)',
       'format an insert statement with sub-query';
};

{
    is $dataset.insert_sql('a', 2, 6.5),
       q[INSERT INTO test VALUES ('a', 2, 6.5)],
       'format an insert statement with array';
};

{
    is $dataset.update_sql('name' => 'abc'),
       q[UPDATE test SET name = 'abc'],
       'format an update statement';
};

{
    is $dataset.clone(:sql('xxx yyy zzz')).select_sql(), 'xxx yyy zzz',
       'return rows for arbitrary SQL';
};

{
    my $sql = 'X';
    my $ds = Squerl::Dataset.new(undef, :$sql);
    is $ds.select_sql(), $sql, ':sql option works for .select_sql';
    is $ds.insert_sql(), $sql, ':sql option works for .insert_sql';
    is $ds.delete_sql(), $sql, ':sql option works for .delete_sql';
    is $ds.update_sql(), $sql, ':sql option works for .update_sql';
    is $ds.truncate_sql(), $sql, ':sql option works for .truncate_sql';
};

sub throws_exception(&block, $expected-type, $message = '') {
    try {
        &block();
    }
    if $! {
        my $got-type = ~$!;
        ok $got-type.substr(0, $expected-type.chars) eq $expected-type,
           $message;
    }
    else {
        is 'ran without failure', $expected-type, $message;
    }
}

$dataset = Squerl::Dataset.new(undef).from('t1', 't2');

todo('not implemented yet', 4);
{
    throws_exception { $dataset.update_sql( a => 1 ) },
                     'Squerl::InvalidOperation',
                     'multi-table dataset dies on .update_sql';

    throws_exception { $dataset.delete_sql() },
                     'Squerl::InvalidOperation',
                     'multi-table dataset dies on .delete_sql';

    throws_exception { $dataset.truncate_sql() },
                     'Squerl::InvalidOperation',
                     'multi-table dataset dies on .truncate_sql';

    throws_exception { $dataset.insert_sql() },
                     'Squerl::InvalidOperation',
                     'multi-table dataset dies on .insert_sql';
};

{
    is $dataset.select_sql, 'SELECT * FROM t1, t2',
       'generate a select query FROM all specified tables';
}

my $ds1 = Squerl::Dataset.new(undef).from('test');
# RAKUDO: A bug prevents us from writing this:
# my $ds2 = $ds1.filter(sql_number('price') < 100);
# my $ds3 = $ds1.filter(sql_number('price') > 50);
my $ds2 = $ds1.filter(sql_number('price').lt(100));
my $ds3 = $ds1.filter(sql_number('price').gt(50));

{
    is $ds1.filter($ds2.exists).sql,
       'SELECT * FROM test WHERE (EXISTS '
       ~ '(SELECT * FROM test WHERE (price < 100)))',
       'Dataset#exists works in filters';
}

done_testing;
