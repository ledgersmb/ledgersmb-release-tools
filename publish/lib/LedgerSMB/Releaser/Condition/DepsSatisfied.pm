package LedgerSMB::Releaser::Condition::DepsSatisfied;


use strict;
use warnings;

use base qw( Workflow::Condition );
use Workflow::Exception qw( condition_error configuration_error );

my @FIELDS = qw( commands );
__PACKAGE__->mk_accessors( @FIELDS );

sub _init {
    my ( $self, $params ) = @_;


    $self->SUPER::_init( $params );

    if (not $params->{'commands'}) {
        configuration_error '';
    }
    $self->commands( [ split /,/, $params->{'commands'} ] );
}

sub evaluate {
    my ( $self, $wf ) = @_;

    for my $cmd ( $self->commands->@* ) {
        system('which', $cmd)
            and condition_error "Failed to assert availability of: $cmd";
    }

    return 1;
}

1;
