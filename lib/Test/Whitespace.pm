package Test::Whitespace;
our $VERSION = '0.0100';


# ABSTRACT: Check your dist for excess whitespace.

use strict;
use warnings;

use Test::Builder ();
use Carp          ();




# Aliases, with a little difference.
# Modules aliases need to work wont be loaded till somebody
# calls the alias :)

sub FFR() {
  require File::Find::Rule;
  require File::Find::Rule::Perl;

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
  require Sub::Install;
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
    $tb->ok( $result->[0], "Test::Whitespace for $_" );
    unless ( $result->[0] == 1 ) {
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

  @files = $f->in( @{$in} );
  return \@files;
}

{

  # THis array is a list of valid tokens for scan_for to contain.
  # Uses table-based execution.
  #
  my $scan_for = {
    'eol'   => sub { $_[1]->tailing; },
    'tab'   => sub { $_[1]->tabs; },
    'extra' => sub { scan_for_extra( $_[1], scalar shift @{ $_[0] } ) },
  };

  sub scan_for_extra {
    my ( $rs, $extra ) = @_;
    for ( @{$extra} ) {
      $rs->add_rule( @{$_} );
    }
    return $rs;
  }

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



=pod

=head1 NAME

Test::Whitespace - Check your dist for excess whitespace.

=head1 VERSION

version 0.0100

=head1 SYNOPSIS

=head2 Declarative

    use Test::Whitespace (
        scan_for => [
            'eol', 'tab' , 'extra' => [
                [ qr/\x504/, '\x504 {{err}}' ],
                [ qr/){/, 'Untidyness {{err}}' ],
            ]
        ]       
        in => [ '/path/to/dir/' ],
        types => sub { $_->perlmodule }, 
    );

Automatically scans for \s+$ , \t and other extra regexen in all
    perl modules in /path/to/dir.

=head2 Objective

    use Test::More plan => 5;
    # Import 2 Symbols for you.
    use Test::Whitespace;

    my $rs = WhitespaceRuleSet
        ->new
        ->tailing
        ->tabs
        ->add_rule( qr/\x504/, '\x504 {{err}}' )
        ->add_rule( qr/){/, 'Untidyness {{err}}' );

    my @files = ( ... );
    for ( @files ){
        my $stat = $rs->test_file( $_ );
        ok( $stat->[0] , "Test for $_ whitespace");
        diag( $stat->[1] ) unless $stat->[0] ;
    }

Works more or less the same, but with more control and doing it the hard way.

=head1 PRIMARY AUDIENCE

This Module is intended for Author Testing and Release testing.

=head1 RATIONALE / PRIMARY AUDIENCE

There are many cases where L<Perl::Critic> is useless to you:

=over 4

=item * You have Non-Perl files that may be shipping with your dist

For example, C<.js> files, C<.yaml> files, C<.json> files, C<.html> files.

=item * You don't care for any other critic policies.

You just want to keep whitespace consistent and repressed.

=item * You have your own weird regex you want to mandate.

And you never want to see that a string in your dist matches that regex, and you really cant be arsed writing a full blown critic policy and uploading it on CPAN for this one tiny case.

=back

In all of the above cases, this module is for you.

=head1 AUTHOR

  Kent Fredric <kentnl at cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Kent Fredric.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut



__END__


