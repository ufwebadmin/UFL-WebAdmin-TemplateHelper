#!perl

use strict;
use warnings;
use File::Spec;
use FindBin;
use Test::More tests => 12;
use UFL::WebAdmin::TemplateHelper;

# get_template
{
    my $template_file = File::Spec->join($FindBin::Bin, 'data', 'simple.tmpl');

    my $helper = UFL::WebAdmin::TemplateHelper->new;
    is($helper->open_delimiter, '<%', 'using default open delimiter');
    is($helper->close_delimiter, '%>', 'using default close delimiter');

    my $template = $helper->get_template($template_file);
    isa_ok($template, 'Text::Template');

    my $content = $template->fill_in(HASH => {
        name => 'get_template',
    });

    is($content, 'Name: get_template' . $/);
}

# get_template with delimiters
{
    my $template_file = File::Spec->join($FindBin::Bin, 'data', 'delimiters.tmpl');

    my $helper = UFL::WebAdmin::TemplateHelper->new({
        open_delimiter => '[%',
        close_delimiter => '%]',
    });
    is($helper->open_delimiter, '[%', 'using specific open delimiter');
    is($helper->close_delimiter, '%]', 'using specific close delimiter');

    my $template = $helper->get_template($template_file);
    isa_ok($template, 'Text::Template');

    my $content = $template->fill_in(HASH => {
        name => 'get_template with delimiters',
    });

    is($content, 'Name: get_template with delimiters' . $/);
}

# fill_template
{
    my $template_file = File::Spec->join($FindBin::Bin, 'data', 'simple.tmpl');

    my $helper = UFL::WebAdmin::TemplateHelper->new;
    is($helper->open_delimiter, '<%', 'using default open delimiter');
    is($helper->close_delimiter, '%>', 'using default close delimiter');

    my %vars = (
        name => 'fill_template',
    );

    my $content = $helper->fill_template($template_file, \%vars);

    is($content, 'Name: fill_template' . $/);
}

# normalize_filename
{
    my $helper = UFL::WebAdmin::TemplateHelper->new;

    my $template_file = File::Spec->join($FindBin::Bin, 'data', 'simple.tmpl');
    my $normalized = $helper->normalize_filename($template_file);

    is($normalized, File::Spec->join('data', 'simple.tmpl'));
}
