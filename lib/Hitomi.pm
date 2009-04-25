use v6;

module Hitomi {
    grammar XML {
        regex TOP {
            ^
              [
              | <opening>               <closing>
              | <opening> <xmlcontent>+ <closing>
              | <empty>
              ]
            $
        };

        rule xmlcontent {
            | <opening>               <closing>
            | <opening> <xmlcontent>+ <closing>
            | <empty>
            | <content>
        };

        rule opening { '<'  <ident> <attr>*     '>' };
        rule closing { '</' <ident>             '>' };
        rule empty   { '<'  <ident> <attr>* '/' '>' };

        rule attr { <.ident>[':'<.ident>]? '=' '"' <-["]>+ '"' }  # '

        token ident { <+alnum + [\-]>+ }

        regex content { <-[<]>+ }
    }
}
