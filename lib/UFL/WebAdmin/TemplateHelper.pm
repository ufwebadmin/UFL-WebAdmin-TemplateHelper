package UFL::WebAdmin::TemplateHelper;

use strict;
use warnings;
use File::Basename ();
use File::Spec;

our $VERSION = '0.04';

=head1 NAME

UFL::WebAdmin::TemplateHelper - Helper functions for filling templates

=head1 SYNOPSIS

    my $template = UFL::WebAdmin::TemplateHelper::get_template('path/to/template.tmpl');
    my $content = UFL::WebAdmin::TemplateHelper::fill_template('path/to/template.tmpl', { name => 'Test' });

=head1 DESCRIPTION

Provides a simple function for filling a L<Text::Template> page.  The
default delimiters are C<<<%>> and C<<%>>>.

=cut

our $DEFAULT_OPEN_DELIMITER = '<%';
our $DEFAULT_CLOSE_DELIMITER = '%>';
our $USER_AGENT_STRING = "UFL-WebAdmin-TemplateHelper/$VERSION ";

=head1 METHODS

=head2 get_url

Fetch the specified URL using L<LWP::UserAgent> and return it. If an
error occurs, the method dies with the HTTP response status.

=cut

sub get_url {
    my ($url) = @_;

    require LWP::UserAgent;

    my $ua = LWP::UserAgent->new;
    $ua->agent($USER_AGENT_STRING);

    my $content = undef;

    my $response = $ua->get($url);
    if ($response->is_success) {
        $content = $response->decoded_content;
    }
    else {
        die $response->status_line;
    }

    return $content;
}

=head2 get_template

Create a template object for the given template file (allows caching
of template object).

    my $template = UFL::WebAdmin::TemplateHelper::get_template('path/to/template.tmpl');
    my $content = $template->fill_in(HASH => { name => 'Test' });

=cut

sub get_template {
    my ($template_file, $open_delimiter, $close_delimiter) = @_;

    # Load the module
    require Text::Template;

    # Determine what template delimiters we are using
    my $template_open_delimiter = $DEFAULT_OPEN_DELIMITER;
    if ((defined $open_delimiter) and ($open_delimiter ne '')) {
        $template_open_delimiter = $open_delimiter;
    }
    my $template_close_delimiter = $DEFAULT_CLOSE_DELIMITER;
    if ((defined $close_delimiter) and ($close_delimiter ne '')) {
        $template_close_delimiter = $close_delimiter;
    }

    # Create the template object
    my $template = Text::Template->new(
        TYPE       => 'FILE',
        SOURCE     => $template_file,
        DELIMITERS => [$template_open_delimiter, $template_close_delimiter],
    ) or die "Couldn't make template: $Text::Template::ERROR";

    return $template;
}

=head2 fill_template

Fill in the given template with the given variables, using
L<Text::Template>.

    my $content = UFL::WebAdmin::TemplateHelper::fill_template('path/to/template.tmpl', { name => 'Test' });

=cut

sub fill_template {
    my ($template_file, $vars, $open_delimiter, $close_delimiter) = @_;

    # Fill in the template
    my $template = get_template($template_file, $open_delimiter, $close_delimiter);

    my $content = $template->fill_in(HASH => $vars);
    die "Error filling template" unless defined $content;

    return $content;
}

=head2 normalize_filename

Based on a full path, return a partial path suitable for use in public
places.

=cut

sub normalize_filename {
    my ($filename) = @_;

    my $normalized = File::Spec->join(
        File::Basename::basename(File::Basename::dirname($filename)),
        File::Basename::basename($filename),
    );

    return $normalized;
}

=head2 debug

Output any arguments as debugging messages.

=cut

sub debug {
    warn "[", scalar localtime, "] ", @_, "\n";
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
