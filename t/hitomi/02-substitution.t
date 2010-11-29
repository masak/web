use v6;
use Test;
use Hitomi;

plan 2;

todo('Hitomi::Stream.render not implemented yet', 2);
{
    my Hitomi::MarkupTemplate $template .= new('<html>
  <h1>Hello, $name!</h1>
</html>
');
    my Hitomi::Stream $stream = $template.generate( :name<world> );
    is $stream.render('html', :doctype(Hitomi::DocType::HTML5)),
       '<!DOCTYPE html>
<html>
  <h1>Hello, world!</h1>
</html>
', 'simple variable substitution works';
}

{
    my Hitomi::MarkupTemplate $template .= new('<html>
  <h1>Hello, ${ $name }</h1></html>
');
    my Hitomi::Stream $stream = $template.generate( :name<world> );
    is $stream.render('html', :doctype(Hitomi::DocType::HTML5)),       '<!DOCTYPE html>
<html>
  <h1>Hello, world!</h1>
</html>
', 'dollar block substitution works';
}
