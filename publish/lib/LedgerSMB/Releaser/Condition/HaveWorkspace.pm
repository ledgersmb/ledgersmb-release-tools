package LedgerSMB::Releaser::Condition::HaveWorkspace;


use strict;
use warnings;

use base qw( Workflow::Condition );
use Workflow::Exception qw( condition_error configuration_error );

my @FIELDS = qw( workspace_context_key );
__PACKAGE__->mk_accessors( @FIELDS );

sub _init {
    my ( $self, $params ) = @_;


    $self->SUPER::_init( $params );

    if (not $params->{'workspace-key'}) {
        configuration_error '';
    }
    $self->workspace_context_key( $params->{'workspace-key'} );
}

sub evaluate {
    my ( $self, $wf ) = @_;
    my $workspace = $wf->context->{ $self->workspace_context_key };

    unless ( $workspace ) {
        condition_error 'Missing context key "' . $self->workspace_context_key . '"';
    }

    unless ( -d $workspace ) {
        condition_error 'Missing workspace directory "' . $workspace . '"';
    }

    return;
}

1;
