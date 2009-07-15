
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'Test-Whitespace',
  NAME      => 'Test::Whitespace',
  AUTHOR    => 'Kent\ Fredric\ \<kentnl\ at\ cpan\.org\>',
  ABSTRACT  => 'Check\ your\ dist\ for\ excess\ whitespace\.',
  VERSION   => '0.0100',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {

  },
);
