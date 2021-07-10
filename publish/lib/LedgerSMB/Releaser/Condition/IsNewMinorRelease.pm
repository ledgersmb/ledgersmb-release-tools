package LedgerSMB::Releaser::Condition::IsNewMinorRelease;


use strict;
use warnings;

use base qw( Workflow::Condition );
use Workflow::Exception qw( condition_error );


sub evaluate {
    my ( $self, $wf ) = @_;
    my $ctx     = $wf->context;
    my $branch  = $ctx->param( 'branch' );
    my $release = $ctx->param( 'release' );

    unless ( $branch ) {
        condition_error "Missing context key 'branch'";
    }
    unless ( $release ) {
        condition_error "Missing context key 'release'";
    }

    unless ( "$branch.0" eq $release ) {
        condition_error "Release $release is not a .0 release for $branch";
    }

    return 1;
}

1;
