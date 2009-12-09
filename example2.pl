use lib "lib";
use WWW::Finger;

my $finger = WWW::Finger->new('mail@tobyinkster.co.uk');
foreach my $pgp_key_uri ($finger->key)
{
	print "$pgp_key_uri\n";
}
