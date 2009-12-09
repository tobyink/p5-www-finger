use strict;
use warnings;

use inc::Module::Install;

license             'perl';

name                'WWW-Finger';
author              'Toby Inkster <tobyink@cpan.org>';
perl_version_from   'lib/WWW/Finger.pm';
version_from        'lib/WWW/Finger.pm';
abstract_from       'lib/WWW/Finger.pm';

test_requires       'Test::More' => '0.61';

requires            'Carp'               => 1.00;
requires            'Digest::MD5'        => 2.00;
requires            'Digest::SHA1'       => 2.00;
requires            'HTTP::Link::Parser' => 0.03;
requires            'LWP::Simple'        => 5.00;
requires            'LWP::UserAgent'     => 5.00;
requires            'RDF::Query'         => 2.200;
requires            'RDF::Query::Client' => 0.02;
requires            'RDF::Trine'         => 0.111;
requires            'XML::LibXML'        => 1.60;
requires            'XRD::Parser'        => 0.02;
requires            'URI'                => 1.30;

auto_install;

sign;

WriteAll;

use Pod::Text;
my $parser = Pod::Text->new (sentence => 0, width => 78);
$parser->parse_from_file('lib/WWW/Finger.pm' => 'README');
