package WWW::Finger;

use WWW::Finger::CPAN;
use WWW::Finger::Fingerpoint;
use WWW::Finger::Webfinger;

BEGIN
{
	my @Modules = ();
}

sub new
{
	my $class      = shift;
	my $identifier = shift;
	
	foreach my $module (@Modules)
	{
		my $rv = $module->new($identifier);
		return $rv
			if defined $rv;
	}
	
	return undef;
}

sub name     { return undef; }
sub mbox     { return undef; }
sub key      { return undef; }
sub image    { return undef; }
sub homepage { return undef; }
sub weblog   { return undef; }
sub endpoint { return undef; }
sub webid    { return undef; }
sub graph    { return undef; }

1;