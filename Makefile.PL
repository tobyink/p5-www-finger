use strict;
use warnings;

use inc::Module::Install;

license             'perl';

name                'WWW-Finger';
author              'Toby Inkster <tobyink@cpan.org>';
perl_version_from   'lib/WWW/Finger.pm';
version_from        'lib/WWW/Finger.pm';
abstract_from       'lib/WWW/Finger.pm';
readme_from         'lib/WWW/Finger.pm';

test_requires       'Test::More' => '0.61';

requires            'Carp'               => '1.00';
requires            'DateTime'           => 0;
requires            'Digest::MD5'        => '2.00';
requires            'Digest::SHA1'       => '2.00';
requires            'Getopt::Long'       => 0;
requires            'HTTP::Link::Parser' => '0.03';
requires            'JSON'               => '2.00';
requires            'LWP::Simple'        => '5.00';
requires            'LWP::UserAgent'     => '5.00';
requires            'Pod::Usage'         => 0;
requires            'RDF::Query'         => '2.200';
requires            'RDF::Query::Client' => '0.02';
requires            'RDF::Trine'         => '0.112';
requires            'XML::LibXML'        => '1.60';
requires            'XRD::Parser'        => '0.04';
requires            'URI'                => '1.30';

install_script 'fingerw';

resources(
	'homepage'   => 'http://search.cpan.org/dist/WWW-Finger/',
	'repository' => 'http://goddamn.co.uk/viewvc/perlmods/WWW-Finger/',
	'bugtracker' => 'https://rt.cpan.org/Dist/Display.html?Queue=WWW-Finger',
	);
	
system("rapper -i turtle -o rdfxml-abbrev Changes >Changes.xml")
	if $Module::Install::AUTHOR;

include 'Test::Signature';
auto_install;
WriteAll(
	'meta' => 1,
	'sign' => 1,
	);
