package LedgerSMB::Releaser::Action::DetectMainModulePath;

use strict;
use warnings;

use base qw( Workflow::Action );
use Workflow::Exception qw( configuration_error workflow_error );


sub execute {
    my ( $self, $wf ) = @_;
    my $ctx = $wf->context;
    my $wsp = $ctx->param( 'our_workspace' );

    ###BUG: don't hardcode the 'ledgersmb/' path!!!
    if ( -f "$wsp/ledgersmb/lib/LedgerSMB.pm" ) {
        $ctx->param( 'module_path', "$wsp/ledgersmb/lib/LedgerSMB.pm" );
        return;
    }

    ###BUG: don't hardcode the 'ledgersmb/' path!!!
    if ( -f "$wsp/ledgersmb/LedgerSMB.pm" ) {
        $ctx->param( 'module_path', "$wsp/ledgersmb/LedgerSMB.pm" );
        return;
    }

    die "Unable to assert the main module's path";
}

1;
