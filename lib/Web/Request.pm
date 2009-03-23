use Web::Utils;

class Web::Request {
    has %.env;

    method body           {  %!env<web.input>      }
    method scheme         {  %!env<web.url_scheme> }
    method script_name    { ~%!env<SCRIPT_NAME>    }
    method path_info      { ~%!env<PATH_INFO>      }
    method port           { +%!env<SERVER_PORT>    }
    method request_method {  %!env<REQUEST_METHOD> }
    method query_string   { ~%!env<QUERY_STRING>   }
    method content_length {  %!env<CONTENT_LENGTH> }
    method content_type   {  %!env<CONTENT_TYPE>   }

    # Returns the data recieved in the query string.
    method GET {
        if %!env<web.request.query_string> eq self.query_string() {
            return %!env<web.request.query_hash>;
        }
        else {
            %!env<web.request.query_string> = self.query_string();
            return %!env<web.request.query_hash>
                = Web::Utils::parse_nested_query(self.query_string());
        }
    }
}

# vim:ft=perl6
