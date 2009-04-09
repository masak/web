class Web::Response {
    has $.length is rw = 0;
    has Int $!status = 200;
    has %!header;
    has @!body = '';
    has &!writer = { @!body.push($^x) };

    # Append to body and update Content-Length.
    #
    # NOTE: Do not mix #write and direct #body access!
    #
    # RAKUDO: '$str as Str'
    method write(Str $str) {
        $!length += $str.chars;
        &!writer($str);

        %!header<Content-Length> = ~$!length;
        return $str;
    }

    method finish() {
        if $!status == 204 | 304 {
            %!header.delete: 'Content-Type';
            return [$!status, %!header, []];
        }
        else {
            return [$!status, %!header, @!body];
        }
    }
}
