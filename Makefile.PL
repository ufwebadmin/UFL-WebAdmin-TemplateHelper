use inc::Module::Install;

name     'UFL-WebAdmin-TemplateHelper';
all_from 'lib/UFL/WebAdmin/TemplateHelper.pm';

requires 'File::Basename';
requires 'File::Spec';
requires 'HTML::Entities';
requires 'LWP::UserAgent';
requires 'Text::Template';
requires 'XML::RSS';

# For script/*
requires_external_bin '/bin/sh';
requires_external_bin '/usr/bin/env';

build_requires 'File::Spec';
build_requires 'FindBin';
build_requires 'Test::More';

WriteAll;
