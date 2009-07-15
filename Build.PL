
use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
  module_name   => 'Test::Whitespace',
  license       => 'perl',
  dist_abstract => "Check\ your\ dist\ for\ excess\ whitespace\.",
  dist_name     => "Test\-Whitespace",
  dist_author   => [
"Kent\ Fredric\ \<kentnl\ at\ cpan\.org\>",
  ],
  requires      => {

  },
  script_files => [ qw() ],
);

$build->create_build_script;
