#!perl

use strict;
use warnings;
use File::Spec;
use FindBin;
use Test::More tests => 6;
use UFL::WebAdmin::TemplateHelper;

# get_template
{
    my $template_file = File::Spec->join($FindBin::Bin, 'data', 'simple.tmpl');

    my $template = UFL::WebAdmin::TemplateHelper::get_template($template_file);
    isa_ok($template, 'Text::Template');

    my $content = $template->fill_in(HASH => {
        name => 'get_template',
    });

    is($content, 'Name: get_template' . $/);
}

# get_template with delimiters
{
    my $template_file = File::Spec->join($FindBin::Bin, 'data', 'delimiters.tmpl');

    my $template = UFL::WebAdmin::TemplateHelper::get_template($template_file, '[%', '%]');
    isa_ok($template, 'Text::Template');

    my $content = $template->fill_in(HASH => {
        name => 'get_template with delimiters',
    });

    is($content, 'Name: get_template with delimiters' . $/);
}

# fill_template
{
    my $template_file = File::Spec->join($FindBin::Bin, 'data', 'simple.tmpl');

    my %vars = (
        name => 'fill_template',
    );

    my $content = UFL::WebAdmin::TemplateHelper::fill_template($template_file, \%vars);

    is($content, 'Name: fill_template' . $/);
}

# normalize_filename
{
    my $template_file = File::Spec->join($FindBin::Bin, 'data', 'simple.tmpl');
    my $normalized = UFL::WebAdmin::TemplateHelper::normalize_filename($template_file);

    is($normalized, File::Spec->join('data', 'simple.tmpl'));
}
