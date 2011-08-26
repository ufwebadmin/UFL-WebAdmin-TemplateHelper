package UFL::WebAdmin::TemplateHelper;

use strict;
use warnings;
use base 'Class::Accessor::Fast';
use Carp;
use File::Basename ();
use File::Spec;
use LWP::UserAgent;
use Text::Template;

__PACKAGE__->mk_accessors(qw/open_delimiter close_delimiter user_agent_string user_agent/);

our $VERSION = '0.05';

=head1 NAME

UFL::WebAdmin::TemplateHelper - Helper functions for filling templates

=head1 SYNOPSIS

    my $helper = UFL::WebAdmin::TemplateHelper->new;
    my $template = $helper->get_template('path/to/template.tmpl');
    my $content = $helper->fill_template('path/to/template.tmpl', { name => 'Test' });

=head1 DESCRIPTION

Provides a simple function for filling a L<Text::Template> page.  The
default delimiters are C<<<%>> and C<<%>>>.

=cut

our $DEFAULT_OPEN_DELIMITER = '<%';
our $DEFAULT_CLOSE_DELIMITER = '%>';
our $DEFAULT_USER_AGENT_STRING = "UFL-WebAdmin-TemplateHelper/$VERSION ";

=head1 METHODS

=head2 new

Create a new L<UFL::WebAdmin::TemplateHelper> object.

=cut

sub new {
    my $self = shift->SUPER::new({
        open_delimiter => $DEFAULT_OPEN_DELIMITER,
        close_delimiter => $DEFAULT_CLOSE_DELIMITER,
        user_agent_string => $DEFAULT_USER_AGENT_STRING,
        %{ ref $_[0] ? $_[0] : {} },
    });

    my $user_agent = LWP::UserAgent->new;
    $user_agent->agent($self->user_agent_string);
    $self->user_agent($user_agent);

    return $self;
}

=head2 get_url

Fetch the specified URL using L<LWP::UserAgent> and return it. If an
error occurs, the method dies with the HTTP response status.

=cut

sub get_url {
    my ($self, $url) = @_;

    my $content = undef;

    my $response = $self->user_agent->get($url);
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

    my $template = $helper->get_template('path/to/template.tmpl');
    my $content = $template->fill_in(HASH => { name => 'Test' });

=cut

sub get_template {
    my ($self, $template_file, $open_delimiter, $close_delimiter) = @_;

    $open_delimiter ||= $self->open_delimiter;
    $close_delimiter ||= $self->close_delimiter;

    # Create the template object
    my $template = Text::Template->new(
        TYPE       => 'FILE',
        SOURCE     => $template_file,
        DELIMITERS => [$open_delimiter, $close_delimiter],
    ) or die "Couldn't make template: $Text::Template::ERROR";

    return $template;
}

=head2 fill_template

Fill in the given template with the given variables, using
L<Text::Template>.

    my $content = UFL::WebAdmin::TemplateHelper::fill_template('path/to/template.tmpl', { name => 'Test' });

=cut

sub fill_template {
    my ($self, $template_file, $vars, $open_delimiter, $close_delimiter) = @_;

    # Fill in the template
    my $template = $self->get_template($template_file, $open_delimiter, $close_delimiter);

    my $content = $template->fill_in(HASH => $vars);
    die "Error filling template" unless defined $content;

    return $content;
}

=head2 normalize_filename

Based on a full path, return a partial path suitable for use in public
places.

=cut

sub normalize_filename {
    my ($self, $filename) = @_;

    my $normalized = File::Spec->join(
        File::Basename::basename(File::Basename::dirname($filename)),
        File::Basename::basename($filename),
    );

    return $normalized;
}

=head2 save_file

Save a file and set permissions appropriately for viewing online. The
parent directory must exist before calling this method; otherwise, an
exception is raised.

=cut

sub save_file {
    my ($self, $content, $filename) = @_;

    umask 022;

    open my $fh, '>', $filename
        or croak "Error opening file $filename: $!";
    print $fh $content;
    close $fh;

    chmod 0664, $filename;
}

=head2 debug

Output any arguments as debugging messages.

=cut

sub debug {
    my $self = shift;

    warn "[", scalar localtime, "] ", @_, "\n";
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
