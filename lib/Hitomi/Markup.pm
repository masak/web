class Hitomi::MarkupTemplate {
    method generate(*%nameds, *@pairs) {
    }
}

class Hitomi::Markup {
    method new($text) {
        return self.bless(*, :$text);
    }
}
