package LedgerSMB::Releaser::Action::CalculateDigests;

use strict;
use warnings;

use base qw( Workflow::Action );
use Workflow::Exception qw( configuration_error workflow_error );

use Digest::SHA;
use File::Spec;

sub execute {
    my ( $self, $wf ) = @_;
    my $ctx = $wf->context;
    my $our_workspace = $ctx->param( 'our_workspace' );
    my $release       = $ctx->param( 'release' );

    my $tgz_sha = Digest::SHA->new(256);
    my $sig_sha = Digest::SHA->new(256);

    my $fn = "ledgersmb-$release.tar.gz";
    $tgz_sha->addfile( File::Spec->catfile($our_workspace, $fn) );
    $sig_sha->addfile( File::Spec->catfile($our_workspace, "$fn.asc") );

    $ctx->param( 'tgz_sha', $tgz_sha->hexdigest );
    $ctx->param( 'sig_sha', $sig_sha->hexdigest );
}

1;
