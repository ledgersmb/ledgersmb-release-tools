package LedgerSMB::Releaser::Action::VersionPatchFiles;

use strict;
use warnings;

use base qw( Workflow::Action );
use Workflow::Exception qw( configuration_error workflow_error );

use File::Find::Rule;

my @FIELDS = qw( exclude src_version_key dst_version_key );
__PACKAGE__->mk_accessors( @FIELDS );


sub init {
    my ( $self, $wf, $params ) = @_;

    $self->SUPER::init( $wf, $params );

    $self->exclude( $params->{exclude} );
    my ($src_version, $dst_version) =
        split /\s*>\s*/, $params->{replace};
    $self->src_version_key( $src_version );
    $self->dst_version_key( $dst_version );
}

sub execute {
    my ( $self, $wf ) = @_;
    my $ctx = $wf->context;

    my @files = ...;
    for my $file (@files) {
        $self->log->info('Patching version in file ', $file);
        open my $fhi, '<', $file
            or die "Unable to open file '$file' for version patching: $!";
        local $/ = undef;

        my $text = <$fhi>;
        close $fhi
            or warn "Unable to close file '$file' after input: $!";

        $text =~ s/\Q$src_version\E/$dst_version/g;

        open my $fho, '>', $file
            or die "Unable to open file '$file' for version patching (output): $!";
        print $fho $text;
        close $fho
            or warn "Unable to close file '$file' after output: $!";
    }
}

1;
