class Web::Response {
    has $.length is rw;
    has %!header;
    has @!body;
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
}
