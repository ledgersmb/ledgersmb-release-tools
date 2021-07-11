package LedgerSMB::Releaser::Action::VersionPatchFiles;

use strict;
use warnings;

use base qw( Workflow::Action );
use Workflow::Exception qw( configuration_error workflow_error );

use File::Find;
use File::Spec;

my @FIELDS = qw( exclude src_version_key dst_version_key );
__PACKAGE__->mk_accessors( @FIELDS );


sub init {
    my ( $self, $wf, $params ) = @_;

    $self->SUPER::init( $wf, $params );

    $self->exclude( $params->{exclude} // '^$' );

    unless ( $params->{replace} ) {
        configuration_error q{Missing 'replace' parameter on action};
    }
    my ($src_version, $dst_version) =
        split /\s*>\s*/, $params->{replace};
    $self->src_version_key( $src_version );
    $self->dst_version_key( $dst_version );
}

sub execute {
    my ( $self, $wf ) = @_;
    my $ctx = $wf->context;
    my $exclude_re  = $self->exclude;
    my $src_version = $ctx->param( $self->src_version_key );
    my $dst_version = $ctx->param( $self->dst_version_key );
    ### BUG! Don't hard-code 'ledgersmb' path
    my $directory   = $ctx->param( 'our_workspace' ) . '/ledgersmb/';

    my %options = (
        no_chdir => 1,
        wanted   => sub {
            my $file = $_;
            return if not -f $file;

            open my $fhi, '<', $file
                or die "Unable to open file '$file' for version patching: $!";
            local $/ = undef;

            my $text = <$fhi>;
            close $fhi
                or warn "Unable to close file '$file' after input: $!";

            if ($text =~ s/\Q$src_version\E/$dst_version/g) {
                $self->log->info('Patching version in file ', $file);
            }

            open my $fho, '>', $file
                or die "Unable to open file '$file' for version patching (output): $!";
            print $fho $text;
            close $fho
                or warn "Unable to close file '$file' after output: $!";
        },
        preprocess => sub {
            return grep {
                my $f = File::Spec->catfile($File::Find::dir, $_);
                $f =~ s/^\Q$directory\E//;

                my $rv = $f !~ m{(?:^[.]git/)|$exclude_re};
                $self->log->trace('Testing file: ', $f,
                                  '; result: ', $rv ? 'included' : 'excluded' );
                $rv
            } @_;
        },
        );
    find(\%options, $directory);
}

1;
