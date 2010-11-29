use v6;
use Test;
use Hitomi;

plan 2;

todo('Hitomi::Stream.render not implemented yet', 2);
{
    my Hitomi::MarkupTemplate $template .= new('<html>
  <h1 pe:for="@list">$_</h1>
</html>
');
    is $template.generate( '@list' => <foo bar baz> ).render('html',
                           :doctype(Hitomi::DocType::HTML5)),
       '<!DOCTYPE html>
<html>
  <h1>foo</h1>
  <h1>bar</h1>
  <h1>baz</h1>
</html>
', 'for loop with loop variable $_ works';
}

{
    my Hitomi::MarkupTemplate $template .= new('<html>
  <h1 pe:for="@list -> $item">$item</h1>
</html>
');
    is $template.generate( '@list' => <foo bar baz> ).render('html',
                           :doctype(Hitomi::DocType::HTML5)),
       '<!DOCTYPE html>
<html>
  <h1>foo</h1>
  <h1>bar</h1>
  <h1>baz</h1>
</html>
', 'for loop with custom loop variable works';
}
