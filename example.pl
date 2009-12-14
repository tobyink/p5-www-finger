#!/usr/bin/perl

use lib "lib";
use lib "../XRD-Parser/lib";

use Data::Dumper;
use XRD::Parser 0.03;

use WWW::Finger qw(+CPAN);

my $finger = WWW::Finger->new('foo_bar@examples.tobyinkster.co.uk');

print $finger->name . "\n";
print $finger->homepage . "\n";
print $finger->image . "\n";
print $finger->mbox . "\n";
print Dumper($finger->graph->as_hashref) . "\n";
