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
use LWP::UserAgent;
use XML::RSS;

use lib '..';
use UFL::WebAdmin::TemplateHelper;


##
## Globals
##

our $DEFAULT_NUMBER_OF_HEADLINES = 2;
our $DEFAULT_NUMBER_OF_SPACES    = 6;
our $DEFAULT_USER_AGENT          = 'University of Florida News/0.1 ';

##
## Main script
##

main(@ARGV);
sub main {
    die usage() unless scalar @_ >= 2;
    my ($url, $template, $number_of_headlines, $number_of_spaces, $user_agent) = @_;
    $number_of_headlines ||= $DEFAULT_NUMBER_OF_HEADLINES;
    $number_of_spaces    ||= $DEFAULT_NUMBER_OF_SPACES;
    $user_agent          ||= $DEFAULT_USER_AGENT;

    my $content = get_url($url, $user_agent);
    debug("Fetched [$url]");

    my $rss = XML::RSS->new;
    $rss->parse($content);
    die 'Error parsing feed' unless @{ $rss->{items} };
    debug("Parsed feed");

    my $normalized = UFL::WebAdmin::TemplateHelper::normalize_filename($template);
    debug("Template = [$template], normalized = [$normalized]");

    my $spaces = ' ' x $number_of_spaces;
    my %vars = (
        rss                 => $rss,
        number_of_headlines => $number_of_headlines,
        spaces              => $spaces,
    );

    my $output = UFL::WebAdmin::TemplateHelper::fill_template($template, \%vars);
    $output .= "$spaces<!-- Generated from $normalized on " . scalar(localtime) . " -->";
    debug("Filled template");

    print $output;
}


##
## Subroutines
##

sub usage {
    return "$0 url template [number of headlines] [number of spaces] [user agent]\n";
}

sub get_url {
    my ($url, $user_agent) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent($user_agent);

    my $content = undef;

    my $response = $ua->get($url);
    if ($response->is_success) {
        $content = $response->content;
    }
    else {
        die $response->status_line;
    }

    return $content;
}

sub debug {
    warn "[", scalar localtime, "] ", @_, "\n";
}
