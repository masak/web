class Web::Response {
    has $.length is rw = 0;
    has Int $!status = 200;
    has %!header;
    has @!body = '';

    # Append to body and update Content-Length.
    #
    # NOTE: Do not mix #write and direct #body access!
    # <masak> seems it should be an rw array attribute.
    # <masak> i.e. 'has @body is rw;'
    # <arthur-_> maybe perl6 has some way we can update $.length when @body is changed from the outside ...
    # <masak> arthur-_: oh, for sure.
    # <arthur-_> that would solve the problem
    # <masak> I think it would require overriding STORE on @body, and that's likely not implemented yet.

    
    #
    # RAKUDO: '$str as Str'
    method write(Str $str) {
        $!length += $str.chars;
        # XXX: For now, we skip the whole 'writer' abstraction found in Rack.
        #      The support for it in Rakudo is flaky, and I don't yet grok
        #      its underlying purpose.
        @!body.push($str);

        %!header<Content-Length> = ~$!length;
        return $str;
    }

    method redirect($target, Int $status = 302) {
      $!status = $status
      %!header<Location> = $target
    }

    method finish() {
        if $!status == 204 | 304 {
            %!header.delete: 'Content-Type';
            return [$!status, \%!header, []];
        }
        else {
            return [$!status, \%!header, \@!body];
        }
    }

    # Read access to the body
    method body () {
        return @!body.join('');
    }    
}
