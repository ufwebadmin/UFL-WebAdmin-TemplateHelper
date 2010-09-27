#!/usr/bin/env perl

##
## Parse an iCal URL and output event information.
##
## Example:
##   ./events.pl \
##     http://www.ufl.edu/calendar/ufCalendar.ics \
##     ../root/www.ufl.edu/events.html.tmpl
##

use strict;
use warnings;
use DateTime;
use FindBin;
use HTML::Entities ();
use iCal::Parser;

use lib "$FindBin::Bin/../lib";
use UFL::WebAdmin::TemplateHelper;


##
## Globals
##

our $DEFAULT_NUM_EVENTS = 2;
our $DEFAULT_NUM_SPACES = 6;

##
## Main script
##

main(@ARGV);
sub main {
    die usage() unless scalar @_ >= 2;
    my ($url, $template, $num_events, $num_spaces) = @_;
    $num_events ||= $DEFAULT_NUM_EVENTS;
    $num_spaces ||= $DEFAULT_NUM_SPACES;

    my $content = UFL::WebAdmin::TemplateHelper::get_url($url);
    UFL::WebAdmin::TemplateHelper::debug("Fetched [$url]");

    my $parser = iCal::Parser->new;
    my $ical = $parser->parse_strings($content);
    die 'Error parsing feed' unless $ical;
    UFL::WebAdmin::TemplateHelper::debug("Parsed feed");

    my $selected_events = select_events($ical->{events}, DateTime->now, $num_events);

    my $normalized = UFL::WebAdmin::TemplateHelper::normalize_filename($template);
    UFL::WebAdmin::TemplateHelper::debug("Template = [$template], normalized = [$normalized]");

    my $spaces = ' ' x $num_spaces;
    my %vars = (
        ical            => $ical,
        selected_events => $selected_events,
        num_events      => $num_events,
        spaces          => $spaces,
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
    return "$0 url template [number of events] [number of spaces]\n";
}

sub select_events {
    my ($events, $dt, $num_events) = @_;

    my @selected;
    while (@selected < $num_events) {
        my $day = $events->{$dt->year}->{$dt->month}->{$dt->day};
        foreach my $uid (keys %$day) {
            push @selected, $day->{$uid};
            last if @selected == $num_events;
        }

        $dt->add(days => 1);
    }

    return \@selected;
}
