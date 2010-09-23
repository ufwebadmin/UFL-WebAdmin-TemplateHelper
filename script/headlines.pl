#!/usr/bin/env perl

##
## Update all configured news publications.
##
## Example:
##   ./headlines.pl \
##     http://news.ufl.edu/research/feed/ \
##     ../root/www.ufl.edu/headlines.html.tmpl
##

use strict;
use warnings;
use HTML::Entities ();
use XML::RSS;

# TODO: Make script and templates installable
use lib '../lib';
use UFL::WebAdmin::TemplateHelper;


##
## Globals
##

our $DEFAULT_NUMBER_OF_HEADLINES = 2;
our $DEFAULT_NUMBER_OF_SPACES    = 6;

##
## Main script
##

main(@ARGV);
sub main {
    die usage() unless scalar @_ >= 2;
    my ($url, $template, $number_of_headlines, $number_of_spaces) = @_;
    $number_of_headlines ||= $DEFAULT_NUMBER_OF_HEADLINES;
    $number_of_spaces    ||= $DEFAULT_NUMBER_OF_SPACES;

    my $content = UFL::WebAdmin::TemplateHelper::get_url($url);
    UFL::WebAdmin::TemplateHelper::debug("Fetched [$url]");

    my $rss = XML::RSS->new;
    $rss->parse($content);
    die 'Error parsing feed' unless @{ $rss->{items} };
    UFL::WebAdmin::TemplateHelper::debug("Parsed feed");

    my $normalized = UFL::WebAdmin::TemplateHelper::normalize_filename($template);
    UFL::WebAdmin::TemplateHelper::debug("Template = [$template], normalized = [$normalized]");

    my $spaces = ' ' x $number_of_spaces;
    my %vars = (
        rss                 => $rss,
        number_of_headlines => $number_of_headlines,
        spaces              => $spaces,
    );

    my $output = UFL::WebAdmin::TemplateHelper::fill_template($template, \%vars);
    $output .= "$spaces<!-- Generated from $normalized on " . scalar(localtime) . " -->";
    UFL::WebAdmin::TemplateHelper::debug("Filled template");

    print $output;
}


##
## Subroutines
##

sub usage {
    return "$0 url template [number of headlines] [number of spaces]\n";
}
