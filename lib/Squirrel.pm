class Squirrel::Dataset {
    method insert(*@values) {
    }
}

class Squirrel::Database {
    has $.file;

    method create_table(*@args) {
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
