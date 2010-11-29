use v6;
use Test;
use Hitomi;

plan 2;

todo('Hitomi::Stream.render not implemented yet', 2);
{
    my Hitomi::MarkupTemplate $template .= new('<html>
  <h1 pe:if="$flag">Hello, world!</h1>
</html>
');
    is $template.generate( :flag(True) ).render('html',
                           :doctype(Hitomi::DocType::HTML5)),
       '<!DOCTYPE html>
<html>
  <h1>Hello, world!</h1>
</html>
', 'true if statement works';
    is $template.generate( :flag(False) ).render('html',
                           :doctype(Hitomi::DocType::HTML5)),
       '<!DOCTYPE html>
<html>
</html>
', 'false if statement works';
}
