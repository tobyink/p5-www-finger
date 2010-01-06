package WWW::Finger::CPAN;

use 5.008001;
use strict;

use Digest::MD5 qw(md5_hex);
use LWP::Simple;
use WWW::Finger;

our @ISA = qw(WWW::Finger);
our $VERSION = '0.06';

BEGIN
{
	push @WWW::Finger::Modules, __PACKAGE__;
}

sub new
{
	my $class = shift;
	my $ident = shift;
	my $self = bless {}, $class;

	$ident = "mailto:$ident"
		unless $ident =~ /^[a-z0-9\.\-\+]+:/i;
	$ident = URI->new($ident);
	
	return undef
		unless $ident;
		
	$self->{'ident'} = $ident;
	
	my ($user, $host) = split /\@/, $self->{'ident'}->to;
	return undef
		unless lc $host eq 'cpan.org';
	
	return $self;
}

sub name
{
	my $self = shift;
	$self->{'pagedata'} = &get( $self->cpanpage )
		unless $self->{'pagedata'};
	my $name = '';
	
	if ($self->{'pagedata'} =~ /<title>(.+) - search.cpan.org/)
	{
		$name = $1;
	}
	else
	{
		my ($user, $host) = split /\@/, $self->{'ident'}->to;
		$name = uc $user;
	}
	if (wantarray)
	{
		return @{ [$name] };
	}
	else
	{
		return $name;
	}
	
}

sub mbox
{
	my $self = shift;
	
	$self->{'pagedata'} = &get( $self->cpanpage )
		unless $self->{'pagedata'};
	my @e;

	if ($self->{'pagedata'} =~ m`<td class=cell><a href="(mailto:[^"]+)">`)
	{
		push @e, $1;
	}
	my ($user, $host) = split /\@/, $self->{'ident'}->to;
	push @e, 'mailto:' . $user . '@cpan.org'
		unless lc $e[0] eq 'mailto:' . $user . '@cpan.org';
	
	if (wantarray)
	{
		return @e;
	}
	else
	{
		return $e[0];
	}
}

sub cpanpage
{
	my $self = shift;
	my ($user, $host) = split /\@/, $self->{'ident'}->to;
	my $cpanpage = 'http://search.cpan.org/~' . $user . '/';
	
	if (wantarray)
	{
		return @{[$cpanpage]};
	}
	else
	{
		return $cpanpage;
	}
}

sub homepage
{
	my $self = shift;
	
	$self->{'pagedata'} = &get( $self->cpanpage )
		unless $self->{'pagedata'};
	my @hp;

	if ($self->{'pagedata'} =~ m`<a href="([^"]+)" rel="me">`)
	{
		push @hp, $1;
	}
	push @hp, $self->cpanpage;
	
	if (wantarray)
	{
		return @hp;
	}
	else
	{
		return $hp[0];
	}
}

sub image
{
	my $self = shift;
	my $md5 = lc md5_hex(lc $self->{'ident'}->to);
	if (wantarray)
	{
		return @{ ["http://www.gravatar.com/avatar/$md5.jpg"] };
	}
	else
	{
		return "http://www.gravatar.com/avatar/$md5.jpg";
	}
}

1;
__END__

=head1 NAME

WWW::Finger::CPAN - WWW::Finger implementation which scrapes cpan.org.

=head1 VERSION

0.06

=head1 DESCRIPTION

Additional methods (other than standard WWW::Finger):

=over 8

=item * C<cpanpage> - returns the person's search.cpan.org homepage.

=back

=head1 SEE ALSO

L<WWW::Finger>.

=head1 AUTHOR

Toby Inkster, E<lt>tobyink@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Toby Inkster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
