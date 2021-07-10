package LedgerSMB::Releaser::Action::RunCommand;

use strict;
use warnings;

use base qw( Workflow::Action );
use Workflow::Exception qw( configuration_error workflow_error );


use File::Temp;

my @FIELDS = qw( command );
__PACKAGE__->mk_accessors( @FIELDS );

sub init {
    my ( $self, $wf, $params ) = @_;

    $self->SUPER::init( $wf, $params );

    for my $field (@FIELDS) {
        $self->$field( $params->{$field} );
        unless ( $params->{$field} ) {
            configuration_error qq{Missing mandatory "$field" configuration};
        }
    }
}

sub execute {
    my ( $self, $wf ) = @_;
    my $ctx = $wf->context;
    my $cmd = $self->command;

    my $tmpfile = File::Temp->new;
    my @args;

    if ($self->command =~ m/^#!/) {
    }
    else {
        @args = ($ENV{SHELL}, $tmpfile->filename);

        print $tmpfile "set -xeo pipefail\n\n";
        print $tmpfile ($self->command =~ s/%(\w+)%/$ctx->param($1)/ger);
        close $tmpfile;
    }
    system(@args)
        and die "Failed to execute @args: $?";
}

1;
