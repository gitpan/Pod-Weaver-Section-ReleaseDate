package Pod::Weaver::Section::ReleaseDate;

use 5.010001;
use Moose;
#use Text::Wrap ();
with 'Pod::Weaver::Role::Section';

#use Log::Any '$log';

use Moose::Autobox;
use POSIX;

our $VERSION = '0.01'; # VERSION
our $DATE = '2014-04-23'; # DATE

sub weave_section {
    my ($self, $document, $input) = @_;

    # check file
    my $filename = $input->{filename};
    unless ($filename =~ m!^(lib|bin|scripts?)/(.+)\.(pm|pl|pod)$!) {
        $self->log_debug(["skipped file %s (not a Perl module/script/POD)",
                          $filename]);
        return;
    }

    # extract date from file
    my $date;
    {
        # XXX does podweaver already provide file content?
        open my($fh), "<", $filename or die "Can't open file $filename: $!";

        local $/;
        my $content = <$fh>;

        if ($content =~ /^\s*our \$DATE = '([^']+)'/m) {
            $date = $1;
            last;
        }
        $date = POSIX::strftime("%Y-%m-%d", localtime);
    }

    unless (defined $date) {
        $self->log_debug(["skipped file %s (no release date defined)",
                          $filename]);
        return;
    }

    # insert POD section
    $document->children->push(
        Pod::Elemental::Element::Nested->new({
            command  => 'head1',
            content  => 'RELEASE DATE',
            children => [
                Pod::Elemental::Element::Pod5::Ordinary->new({ content => $date }),
            ],
        }),
    );
}

no Moose;
1;
# ABSTRACT: Add a RELEASE DATE section (from package's $DATE)

__END__

=pod

=encoding UTF-8

=head1 NAME

Pod::Weaver::Section::ReleaseDate - Add a RELEASE DATE section (from package's $DATE)

=head1 VERSION

version 0.01

=head1 RELEASE DATE

2014-04-23

=head1 SYNOPSIS

In your C<weaver.ini>:

 [ReleaseDate]

=head1 DESCRIPTION

This section plugin adds a RELEASE DATE section to Perl modules/scripts. Release
date is taken from module's C<$DATE> package variable (extracted using regexp)
or, if not available, from the current date.

=for Pod::Coverage weave_section

=head1

=head1 SEE ALSO

L<Pod::Weaver::Section::Version>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Pod-Weaver-Section-ReleaseDate>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Pod-Weaver-Section-ReleaseDate>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Pod-Weaver-Section-ReleaseDate>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
