package Test::Whitespace;

# ABSTRACT: Check your dist for excess whitespace.

use strict;
use warnings;

use Sub::Install           ();
use Test::Builder          ();
use File::Find::Rule       ();
use File::Find::Rule::Perl ();
use Carp                   ();

=head1 SYNOPSIS

    use Test::Whitespace (
        scan_for => [
            'eol', 'tab' , 'extra' => [
                [ qr/\x504/, '\x504 {{err}}' ],
                [ qr/){/, 'Untidyness {{err}}' ],
            ]
        ]       
        in => [ '/path/to/dir/' ],
        types => sub { $_->perlmodule }, 
        files => [ ],
    );

=cut

# Aliases
sub FFR() {
  'File::Find::Rule';
}

sub WhitespaceRule {
  require Test::Whitespace::Rule;
  'Test::Whitespace::Rule';
}

sub WhitespaceRuleSet {
  require Test::Whitespace::RuleSet;
  'Test::Whitespace::RuleSet';
}

# Inject Aliases into calling scope and let them do it themsleves.

sub import_subs {
  my $caller = shift;
  Sub::Install::install_sub( { code => \&WhitespaceRule,    into => $caller, as => 'WhitespaceRule', } );
  Sub::Install::install_sub( { code => \&WhitespaceRuleSet, into => $caller, as => 'WhitespaceRuleSet', } );
  return;
}

sub import_autotest {
  my ( $caller, $args ) = @_;

  unless ( exists $args->{'files'} or exists $args->{'in'} ) {
    Carp::croak("No Scan path  for files and no files");
  }

  unless ( exists $args->{'files'} ) {
    $args->{'files'} = find_files( $args->{'in'}, $args->{'types'} );
  }

  my $tb = Test::Builder->new();
  $tb->plan( scalar @{ $args->{'files'} } );

  my $rs = WhitespaceRuleSet->new();
  inject_rules( $rs, $args );

  for ( @{ $args->{'files'} } ) {
    my $result = $rs->test_file($_);
    if ( $result->[0] == 1 ) {
      $tb->ok( 1, "Test::Whitespace for $_" );
    }
    else {
      $tb->ok( 0, "Test::Whitespace for $_" );
      for ( @{ $result->[1] } ) {
        $tb->diag($_);
      }
    }
  }
}

sub find_files {
  my ( $in, $types ) = @_;
  my ( @files, $f );

  $f = FFR->new->file;

  if ($types) {
    local $_ = $f;
    $f = $types->();
  }

  @files = $f->in( @{ $in  } );
  return \@files;
}

{

  # THis array is a list of valid tokens for scan_for to contain.
  # Uses table-based execution.
  #
  my $scan_for = {
    'eol'   => sub { $_[1]->tailing; },
    'tab'   => sub { $_[1]->tabs; },
    'extra' => sub { $_[1]->add_rule( @{$_} ) for @{ ( shift @{ $_[0] } ) } },
  };

  sub inject_rules {

    my ( $rs, $args ) = @_;

    my @scan_for_items = @{ $args->{'scan_for'} };

  rule: while (@scan_for_items) {

      my $item = shift @scan_for_items;

      if ( exists $scan_for->{$item} ) {

        $scan_for->{$item}->( \@scan_for_items, $rs );

        next rule;
      }

      Carp::cluck("Parameter not recognised $item ");
    }
  }
}

sub import {
  my $class  = shift;
  my $caller = caller();
  my %args   = @_;

  unless (@_) {
    return import_subs($caller);
  }

  return import_autotest( $caller, \%args );
}
1;
__END__


