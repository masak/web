use SQLite3;

class Squirrel::Dataset {
    has $!db;
    has $!table;

    method insert(*@values) {
        my $values = @values>>.perl.join(', ');
        given $!db {
            .open;
            .exec("INSERT INTO $!table VALUES($values)");
            .close;
        }
    }

    method all() {
        $!db.select("*", $!table);
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

    method select($_: $what, $table) {
        my @rows;
        .open;
        warn "SELECT $what FROM $table";
        my $sth = $!dbh.prepare("SELECT $what FROM $table");
        while $sth.step() == 100 {
            warn "In the loop";
            push @rows, [map { $sth.column_text($_) }, ^$sth.column_count()];
        }
        .close;
        return @rows;
    }

    method from($table) {
        return Squirrel::Dataset.new(:db(self), :$table);
    }
}

class Squirrel {
    method sqlite($file) {
        return Squirrel::Database.new(:$file);
    }
}
