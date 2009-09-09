use SQLite3;

class Squirrel::Dataset {
    method insert(*@values) {
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

    method create_table(*@args) {
        given self {
            .open;
            .exec('CREATE TABLE foo (item,count)');
            .close;
        }
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
