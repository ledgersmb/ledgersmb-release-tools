package LedgerSMB::Releaser::Action::CreateWorkspace;

use strict;
use warnings;

use base qw( Workflow::Action );
use Workflow::Exception qw( configuration_error workflow_error );


use File::Temp;

my @FIELDS = qw( context_key clone_url clone_dir );
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
    my $key = $self->context_key;
    my $url = $self->clone_url;
    my $tgt = $self->clone_dir;
    my $b   = $ctx->param( 'branch' );

    $ctx->param( $key, File::Temp->newdir( CLEANUP => 0 )->dirname );
    my $workspace = $ctx->param( $key );
    my @args = ( 'git', 'clone', '--single-branch', '--recursive', '-b', $b,
                 $url, "$workspace/$tgt" );
    system(@args)
        and die "Failed to clone '$url' into '$workspace/$tgt': $?";
}

1;
