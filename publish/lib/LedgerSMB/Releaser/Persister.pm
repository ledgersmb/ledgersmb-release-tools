package LedgerSMB::Releaser::Persister;


use strict;
use warnings;


use base qw( Workflow::Persister::File );



sub init {
    my ( $self, $params ) = @_;

    if ($params->{path} =~ s/(?<!\\)\$(\w*)/$ENV{$1}/g) {
        $self->log->info('Storage path after expansion: ', $params->{path});
    }
    if (not -e $params->{path}) {
        mkdir( $params->{path} )
            or die "Unable to create workflow storage path ($params->{path}): $!";

        $self->log->info('Storage path created: ', $params->{path});
    }
    if (not -d $params->{path}) {
        die "Workflow storage path ($params->{path}) expected to be a directory";
    }

    $self->SUPER::init($params);
}


1;
