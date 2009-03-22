use Test;
use Web::Happle;
use TestFiles;

plan 2;

{
    my @basic = Happle.parse(TestFiles::BASIC);
    @basic.search('//p').set('class', 'para');
    is 4, @basic.search('//p').elems, 'same number of elements afterwards';
    is 4, @basic.search('//p').find-all( { $^x.ix['class'] eq 'para' } ).elems,
       'all elements now have a class "para" on them';
}

