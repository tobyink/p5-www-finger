use strict;
use warnings;

use inc::Module::Install;

my $dist = 'WWW-Finger';
my $fn   = "lib/$dist.pm"; $fn =~ s#-#/#g;

name                $dist;
perl_version_from   $fn;
version_from        $fn;
abstract_from       $fn;
readme_from         $fn;
author              'Toby Inkster <tobyink@cpan.org>';
license             'perl';

test_requires       'Test::More' => '0.61';

requires            'Carp'               => '1.00';
requires            'common::sense'      => 0;
requires            'DateTime'           => 0;
requires            'Digest::MD5'        => '2.00';
requires            'Digest::SHA1'       => '2.00';
requires            'Getopt::Long'       => 0;
requires            'HTTP::Link::Parser' => '0.03';
requires            'HTTP::LRDD'         => '0.103';
requires            'JSON'               => '2.00';
requires            'LWP::Simple'        => '5.00';
requires            'LWP::UserAgent'     => '5.00';
requires            'Pod::Usage'         => 0;
requires            'RDF::Query'         => '2.200';
requires            'RDF::Query::Client' => '0.02';
requires            'RDF::Trine'         => '0.112';
requires            'XML::LibXML'        => '1.60';
requires            'XRD::Parser'        => '0.100';
requires            'URI'                => '1.30';

resources(
	'homepage'   => "https://metacpan.org/release/$dist",
	'repository' => "http://goddamn.co.uk/svn-web/perlmods/browse/$dist/",
	'bugtracker' => "http://rt.cpan.org/Dist/Display.html?Queue=$dist",
	);

write_doap_changes;
write_doap_changes_xml;

install_script 'fingerw';

include 'Test::Signature';
auto_install;
WriteAll(
	'meta' => 1,
	'sign' => 1,
	);
