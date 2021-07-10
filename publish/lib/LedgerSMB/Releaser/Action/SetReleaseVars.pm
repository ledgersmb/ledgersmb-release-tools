package LedgerSMB::Releaser::Action::SetReleaseVars;

use strict;
use warnings;

use base qw( Workflow::Action );
use Workflow::Exception qw( configuration_error workflow_error );


sub execute {
    my ( $self, $wf ) = @_;
    my $ctx = $wf->context;
    my $release = $ctx->param( 'release' );
    my $current = $ctx->param( 'current_version' );

    my $suffix  = ($current =~ s/(\d+[.]\d+[.])(\d+)//r); # remove the version number
    my $mm_ver  = $1;
    my $patch   = $2;
    my $branch_next = sprintf("$1.%s%s", ($patch + 1), $suffix);

    if (not $release) {
        $release = "$mm_ver.$patch";
        $ctx->param( 'release', $release );
    }

    $ctx->param( 'next_release', $branch_next );
    if ($release =~ m/[-]/) {
        # prerelease version

        $ctx->param( 'tagged', '' );
        $ctx->param( 'download_dir', 'Beta Releases' );
    }
    else {
        # official release version

        $ctx->param( 'tagged', 'yes' );
        $ctx->param( 'download_dir', 'Releases' );
    }
}

1;
