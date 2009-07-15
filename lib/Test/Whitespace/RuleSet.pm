package Test::Whitespace::RuleSet;

# ABSTRACT: Bundle a bunch of Expression/Message rules.
#
# $Id:$

use strict;
use warnings;
use Moose;
use MooseX::AttributeHelpers;
use namespace::autoclean;
use Test::Whitespace::Rule;

has _rules => (
  isa       => 'ArrayRef[Test::Whitespace::Rule]',
  is        => 'rw',
  default   => sub { [] },
  metaclass => 'Collection::Array',
  provides  => {
    push     => 'add_rule_entry',
    elements => 'rules',
  }
);

sub add_rule {
  my $self       = shift;
  my $expression = shift;
  my $message    = shift;
  my $obj        = Test::Whitespace::Rule->new(
    expression => $expression,
    message    => $message,
  );
  $self->add_rule_entry($obj);
  return $self;
}

sub tailing {
  my $self = shift;
  $self->add_rule( qr/\h$/m, '\h {{err}}' );
  return $self;
}

sub tabs {
  my $self = shift;
  $self->add_rule( qr/\t/m, '\t {{err}' );
  return $self;
}

sub test_string {
  my ( $self, $line, $lineno, $file ) = @_;
  my @diag;
  my $ok = 1;
  for ( $self->rules ) {
    next unless $_->test( $line, $lineno, $file );
    push @diag, $_->diagnostic( $line, $lineno, $file );
    $ok = 0;
  }
  if ($ok) {
    return [ 1, [] ];
  }
  return [ 0, \@diag ];
}

sub test_file {
  my ( $self, $file ) = @_;
  my @diag = ();
  my $ok   = 1;
  my $fh;
  if ( not open $fh, '<', $file ) {
    return [ 0, "Loading $file failed" ];
  }

  while ( my $line = <$fh> ) {
    my $result = $self->test_string($line);
    next if $result->[0] == 1;
    $ok = 0;
    push @diag, @{ $result->[1] };
  }
  return [ $ok, \@diag ];
}
1;

