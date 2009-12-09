#!/usr/bin/perl

use lib "lib";
use WWW::Finger;

my $finger = WWW::Finger->new('mailto:tobyink@cpan.org');

print $finger->name . "\n";
print $finger->homepage . "\n";
print $finger->image . "\n";
print $finger->mbox . "\n";
