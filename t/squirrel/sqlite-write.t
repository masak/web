use v6;
use Test;

use Squirrel;

unlink (my $file = 't/squirrel/posts.db');
my $DB = Squirrel.sqlite($file);

$DB.create_table: <posts
    primary_key id
    Int         user_id
    String      name
>;

#my $posts = $DB<posts>;
my $posts = $DB.from('posts');

$posts.insert(0, 1, 'Hello Austria!');

ok $file ~~ :e, 'could create the database file';

my $number-of-posts = +$posts.all;

is $number-of-posts, 1, 'could insert and then retrieve a row';

unlink $file;
