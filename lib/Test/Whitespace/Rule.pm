package Test::Whitespace::Rule;

# ABSTRACT: Expression/Message test-container for various whitespace checks
#
# $Id:$

use strict;
use warnings;
use Moose;
use Data::Dumper;
use namespace::autoclean;

has expression => (
  isa      => 'RegexpRef',
  is       => 'ro',
  required => 1,
);

has message => (
  isa      => 'Str',
  is       => 'ro',
  required => 1,
);

sub diagnostic {
  my ( $self, $line, $lineno, $file ) = @_;
  local $Data::Dumper::Terse  = 1;
  local $Data::Dumper::Useqq  = 1;
  local $Data::Dumper::Indent = 0;
  my $line_pp = Data::Dumper::Dumper($line);
  my $message = $self->message;
  my $errmsg = "found on ${lineno} in ${file}: >>>${line}<<<";
  $message =~ s[ {{lineno}} ][ $lineno  ]gex;
  $message =~ s[ {{line}}   ][ $line_pp ]gex;
  $message =~ s[ {{file}}   ][ $file    ]gex;
  $message =~ s[ {{err}}    ][ $errmsg  ]gex; 
  return $message;
}

sub test {
  my ( $self, $line, $lineno, $file ) = @_;
  return ( $line =~ $self->expression );
}

__PACKAGE__->meta->make_immutable;
1;

