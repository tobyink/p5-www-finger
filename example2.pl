use lib "lib";
use Data::Dumper;
use WWW::Finger;

my $finger = WWW::Finger->new('mail@tobyinkster.co.uk');
foreach my $pgp_key_uri ($finger->key)
{
	print "$pgp_key_uri\n";
}

print Dumper([ $finger->get('http://xmlns.com/foaf/0.1/phone') ]);

print Dumper([ $finger->get(qw'http://xmlns.com/foaf/0.1/aimChatID http://xmlns.com/foaf/0.1/yahooChatID http://xmlns.com/foaf/0.1/icqChatID') ]);
