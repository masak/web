use Text::CSV;

class Viper {
    has $.db;
    has %.objects;

    submethod BUILD(:@types!, :$db!) {
        $!db    = $db;
        if $db !~~ :e {
            run("mkdir $db");
        }
        for @types -> $type {
            my $filename = $!db ~ '/' ~ $type.substr(0,-2);
            if $filename !~~ :e {
                self.create-new-db-file($type, $filename);
                %!objects{$type} = [];
            }
            else {
                %!objects{$type}
                    = Text::CSV.parse-file($filename, :output($type));
            }
        }
    }

    submethod create-new-db-file($type, $filename) {
        my @columns = $type.^attributes>>.name>>.substr(2); # w/o sigil/twigil
        my $dbfile = open($filename, :w)
            or die $!;
        $dbfile.say: join(',', map { quote($_) }, @columns);
    }

    sub quote($s) { qq["$s"] }
}

class Viper::Base {
    has $.id is persisted;
    has $.name is persisted;

    method find(Viper $session, :$all) {
        return $session.objects{self}.list;
    }
}

multi trait_mod:<is>(AttributeDeclarand $a, :$persisted!) {
}
