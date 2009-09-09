use SQLite3;

class Squirrel::Dataset {
    method insert(*@values) {
    }

    method all() {
        return [];
    }
}

class Squirrel::Database {
    has $!file;
    has $!dbh;

    submethod BUILD(:$file!) {
        $!file = $file; # RAKUDO: This shouldn't be needed
    }

    method open() {
        $!dbh = sqlite_open($!file);
    }

    method close() {
        $!dbh.close();
    }

    method exec($statement) {
        my $sth = $!dbh.prepare($statement);
        $sth.step();
        $sth.finalize();
    }

    method create_table($_: *@args) {
        my $table-name = @args[0];
        my $columns = join ', ', gather for @args[1..^*] -> $type, $name {
            given $type.lc {
                when 'primary_key'   { take "$name INTEGER PRIMARY KEY ASC" }
                when 'int'|'integer' { take "$name INTEGER" }
                when 'str'|'string'  { take "$name TEXT" }
                default              { die "Unknown type $type" }
            }
        };
        .open;
        .exec("CREATE TABLE $table-name ($columns)");
        .close;
    }

    method from($table) {
        return Squirrel::Dataset.new();
    }
}

class Squirrel {
    method sqlite($file) {
        return Squirrel::Database.new(:$file);
    }
}
