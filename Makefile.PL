use inc::Module::Install;

name     'UFL-WebAdmin-TemplateHelper';
all_from 'lib/UFL/WebAdmin/TemplateHelper.pm';

requires 'File::Basename';
requires 'File::Spec';
requires 'Text::Template';

build_requires 'Test::More';

WriteAll;
