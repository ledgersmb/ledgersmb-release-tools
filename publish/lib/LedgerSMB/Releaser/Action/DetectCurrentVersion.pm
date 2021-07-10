package LedgerSMB::Releaser::Action::DetectCurrentVersion;

use strict;
use warnings;

use base qw( Workflow::Action );
use Workflow::Exception qw( configuration_error workflow_error );


sub execute {
    my ( $self, $wf ) = @_;
    my $ctx = $wf->context;
    my $p   = $ctx->param( 'module_path' );

    open my $fh, "<", $p
        or die "Failed to open file '$p': $!";
    while (my $line = <$fh>) {
        if ($line =~ m/^our \$VERSION = '(.+)';$/) {
            $ctx->param( 'current_version', $1 );
            return;
        }
    }

    die "Unable to assert the main module's version";
}

1;
