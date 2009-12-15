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

requires            'Carp'               => 1.00;
requires            'Digest::MD5'        => 2.00;
requires            'Digest::SHA1'       => 2.00;
requires            'HTTP::Link::Parser' => 0.03;
requires            'LWP::Simple'        => 5.00;
requires            'LWP::UserAgent'     => 5.00;
requires            'RDF::Query'         => 2.200;
requires            'RDF::Query::Client' => 0.02;
requires            'RDF::Trine'         => 0.112;
requires            'XML::LibXML'        => 1.60;
requires            'XRD::Parser'        => 0.03;
requires            'URI'                => 1.30;

auto_set_homepage;
auto_set_bugtracker;

include 'Test::Signature';
auto_install;
WriteAll(
	'meta' => 1,
	'sign' => 1,
	);
