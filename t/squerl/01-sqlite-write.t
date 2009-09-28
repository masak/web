use v6;
use Test;

use Squerl;

unlink (my $file = 't/squerl/posts.db');
my $DB = Squerl.sqlite($file);

$DB.create_table: 'posts',
    'id'      => 'primary_key',
    'user_id' => 'Int',
    'name'    => 'String',
;

#my $posts = $DB<posts>;
my $posts = $DB.from('posts');

$posts.insert(0, 1, 'Hello Austria!');

ok $file ~~ :e, 'could create the database file';

my $number-of-posts = +$posts.all;

is $number-of-posts, 1, 'could insert and then retrieve a row';

done_testing;

unlink $file;
