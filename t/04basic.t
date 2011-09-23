#!perl

use strict;
use warnings;
use File::Basename ();
use File::Path ();
use File::Spec;
use FindBin;
use Test::More tests => 15;
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

# comment_html
{
    my $helper = UFL::WebAdmin::TemplateHelper->new;

    my $template_file = File::Spec->join($FindBin::Bin, 'data', 'simple.tmpl');
    my $comment = $helper->comment_html($template_file);

    my $filename = File::Spec->join('data', 'simple.tmpl');
    like($comment, qr/^<!-- Generated from $filename on .+ \d{4} -->$/);
}

# save_file
{
    my $helper = UFL::WebAdmin::TemplateHelper->new;

    my $dir = File::Spec->join($FindBin::Bin, 'var');
    my $file = File::Spec->join($dir, 'save_file.txt');

    File::Path::make_path(File::Basename::dirname($file))
        unless -d $dir;
    unlink $file;

    $helper->save_file('test', $file);

    ok(-f $file, 'file exists');

    my @stat = stat $file;
    is(sprintf("%o", $stat[2]), 100664, 'permissions are set correctly');
}
