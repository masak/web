use v6;
use Hitomi::Serializer;

enum Hitomi::StreamEventKind <start end text xml-decl doctype start-ns end-ns
                              start-cdata end-cdata pi comment>;

class Hitomi::Stream {
    has @!events;
    has Hitomi::Serializer $serializer;

    multi method new(@events, $serializer?) {
        return self.new(:events(@events), :serializer($serializer));
    }

    # RAKUDO: We shouldn't have to provide this method. It should be handed
    #         to us by C<Object>.
    multi method new(*%_) {
        return self.bless(self.CREATE(), |%_);
    }

    method Str() {
        return [~] @!events;
    }
}
