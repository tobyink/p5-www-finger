package WWW::Finger::Webfinger;

use 5.008001;
use strict;

use Carp;
use LWP::Simple;
use RDF::Query;
use RDF::Trine;
use WWW::Finger;
use URI;
use URI::Escape;
use XRD::Parser 0.02;

our @ISA = qw(WWW::Finger);
our $VERSION = '0.01';

sub new
{
	my $class = shift;
	my $ident = shift or croak "Need to supply an e-mail address\n";
	my $self  = bless {}, $class;
		
	$ident = "acct://$ident"
		unless $ident =~ /^[a-z0-9\.\-\+]+:/i;
	$ident = URI->new($ident);
	return undef
		unless $ident->scheme =~ /^(mailto|acct|xmpp)$/;

	$self->{'ident'} = $ident;
	my ($user, $host) = split /\@/, $ident->to;
	
	my $ua = LWP::UserAgent->new;
	$ua->timeout(10);
	$ua->env_proxy;

	my $xrd_parser = XRD::Parser->new(undef,
		sprintf("http://%s/.well-known/host-meta", $host));
	$xrd_parser->consume;
	$self->{'hostmeta'} = $xrd_parser->graph;
	
	my @descriptors;
	my $sparql  = sprintf("SELECT ?template WHERE { <%s> <%s> ?template . }",
		('http://ontologi.es/xrd#host:' . lc $host),
		'x-xrd+template+for:http://lrdd.net/rel/descriptor');
	my $query   = RDF::Query->new($sparql);
	my $results = $query->execute( $self->{'hostmeta'} );
	while (my $row = $results->next)
	{
		next
			unless $row->{'template'}->is_literal;
		next
			unless $row->{'template'}->literal_datatype eq 'http://ontologi.es/xrd#URITemplate';
			
		my $template = $row->{'template'}->literal_value;
		my $escaped  = uri_escape("$ident");
		$template = s/\{uri\}/$escaped/;
		
		push @descriptors, $template;
	}
	
	use Data::Dumper;
	warn Dumper(\@descriptors);
}

1;
__END__
=head1 NAME

WWW::Finger::Webfinger - WWW::Finger module for Webfinger

=head1 AUTHOR

Toby Inkster, E<lt>tobyink@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Toby Inkster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
