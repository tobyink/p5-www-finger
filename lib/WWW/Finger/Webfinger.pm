package WWW::Finger::Webfinger;

use 5.008001;
use strict;

use Carp;
use LWP::UserAgent;
use RDF::Query;
use RDF::Trine 0.112;
use WWW::Finger;
use URI;
use URI::Escape;
use XRD::Parser 0.04;

our @ISA = qw(WWW::Finger::_GenericRDF);
our $VERSION = '0.08';

BEGIN
{
	push @WWW::Finger::Modules, __PACKAGE__;
}

sub new
{
	my $class = shift;
	my $ident = shift or croak "Need to supply an account address\n";
	my $self  = bless {}, $class;

	$ident = "acct:$ident"
		unless $ident =~ /^[a-z0-9\.\-\+]+:/i;
	$ident = URI->new($ident);
	return undef
		unless $ident->scheme =~ /^(mailto|acct|xmpp)$/;

	$self->{'ident'} = $ident;
	my ($user, $host) = split /\@/, $ident->authority;
	if ("$ident" =~ /^(acct|mailto)\:([^\s\@]+)\@([a-z0-9\-\.]+)$/i)
	{
		$user = $2;
		$host = $3;
	}
	
	eval {
		my $xrd_parser = XRD::Parser->hostmeta($host);
		$xrd_parser->consume;
		$self->{'hostmeta'} = $xrd_parser->graph;
	};
	return undef unless defined $self->{'hostmeta'};
	
	my @descriptors;
	my $sparql  = sprintf("SELECT DISTINCT ?template WHERE { { <%s> <%s> ?template . } UNION { <%s> <%s> ?template . } }",
		('http://ontologi.es/xrd#host:' . lc $host),
		'x-xrd+template+for:http://lrdd.net/rel/descriptor',
		('http://ontologi.es/xrd#host:' . lc $host),
		'x-xrd+template+for:http://www.iana.org/assignments/relation/lrdd',
		);
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
		$template =~ s/\{uri\}/$escaped/g;
		
		push @descriptors, $template;
	}
	
	my $ua = LWP::UserAgent->new;
	$ua->timeout(10);
	$ua->env_proxy;
	$ua->default_header('Accept' => 'application/rdf+xml, text/turtle, application/x-rdf+json, application/xrd+xml;q=0.5, */*;q=0.01');

	foreach my $d (@descriptors)
	{
		eval
		{
			my $response = $ua->get($d);
			die unless $response->is_success;
			
			if ($response->content_type =~ /xrd/i)
			{
				my $profile_parser = XRD::Parser->new($response->decoded_content, $d);
				$profile_parser->consume;
				
				$self->{'graph'} = $profile_parser->graph;
			}
			else
			{
				my $parser;
				$parser = RDF::Trine::Parser::Turtle->new  if $response->content_type =~ m`(n3|turtle|text/plain)`;
				$parser = RDF::Trine::Parser::RDFJSON->new if $response->content_type =~ m`(json)`;
				$parser = RDF::Trine::Parser::RDFXML->new  unless defined $parser;
				
				my $model  = RDF::Trine::Model->new( RDF::Trine::Store->temporary_store );
				$parser->parse_into_model($d, $response->decoded_content, $model);
				
				$self->{'graph'} = $model;
			}
		};
		last
			if defined $self->{'graph'} && $self->{'graph'}->count_statements;
	}
	
	return undef
		unless defined $self->{'graph'} && $self->{'graph'}->count_statements;
	
	$self->follow_seeAlso(0);
	
	return $self;
}

sub _simple_sparql
{
	my $self = shift;
	my $where = '';
	foreach my $p (@_)
	{
		$where .= " UNION " if length $where;
		$where .= sprintf('{ <%s> <%s> ?x . } '
				. 'UNION { ?z xrd:alias <%s> ; <%s> ?x . } '
				. 'UNION { ?z <http://xmlns.com/foaf/0.1/account> <%s> ; <%s> ?x . } '
				. 'UNION { ?z <http://xmlns.com/foaf/0.1/holdsAccount> <%s> ; <%s> ?x . }',
			(''.$self->{'ident'}), $p,
			(''.$self->{'ident'}), $p,
			(''.$self->{'ident'}), $p,
			(''.$self->{'ident'}), $p,
			);
	}
	
	my $sparql = "PREFIX xrd: <http://ontologi.es/xrd#> SELECT DISTINCT ?x WHERE { $where }";
	my $query  = RDF::Query->new($sparql);
	my $iter   = $query->execute( $self->{'graph'} );
	my @results;
	
	while (my $row = $iter->next)
	{
		push @results, $row->{'x'}->literal_value
			if $row->{'x'}->is_literal;
		push @results, $row->{'x'}->uri
			if $row->{'x'}->is_resource;
	}
	
	if (wantarray)
	{
		return @results;
	}
	
	if (@results)
	{
		return $results[0];
	}
	
	return undef;
}

sub webid
{
	my $self = shift;
	return $self->SUPER::webid(@_);
}

1;
__END__
=head1 NAME

WWW::Finger::Webfinger - WWW::Finger module for Webfinger

=head1 VERSION

0.08

=head1 DESCRIPTION

Webfinger is currently a very unstable specification, with implementation details
changing all the time. Given this instability, it seems prudent to describe the
protocol, as implemented by this package.

Given an e-mail-like identifier, the package will prepend "acct:" to it, assuming that
the identifier doesn't already have a URI scheme. This identifier will now be called
[ident].

The package looks up the host-meta file associated with the host for [ident].
It is assumed to be formatted according to the draft-hammer-hostmeta-05
Internet Draft L<http://tools.ietf.org/html/draft-hammer-hostmeta-05> and
XRD Working Draft 10 <http://www.oasis-open.org/committees/download.php/35274/xrd-1.0-wd10.html>.
Both these drafts are dated 19 November 2009.

A link template will be extracted from the host-meta for the host using either
of the following two relationships: L<http://lrdd.net/rel/descriptor>,
L<http://www.iana.org/assignments/relation/lrdd>. (Neither is prioritised, so
if both exist and have different templates, hilarity will ensue.)

The token "{uri}" in the link template will be replaced with the URL-encoded
version of [ident] to create an account descriptor URI.

The account descriptor URI is fetched via HTTP GET with an Accept header
asking for RDF/XML, Turtle, RDF/JSON or XRD. The result is parsed for account
description data if it has status code 200 (OK).

The following relationships/properties are understood in the account
description:

=over 8

=item * http://xmlns.com/foaf/0.1/name

=item * http://xmlns.com/foaf/0.1/homepage

=item * http://webfinger.net/rel/profile-page

=item * http://xmlns.com/foaf/0.1/weblog

=item * http://xmlns.com/foaf/0.1/mbox

=item * http://webfinger.net/rel/avatar

=item * http://xmlns.com/foaf/0.1/img

=item * http://xmlns.com/foaf/0.1/depiction

=item * http://ontologi.es/sparql#endpoint

=back

=head1 SEE ALSO

L<WWW::Finger>, L<XRD::Parser>.

L<http://code.google.com/p/webfinger/>.

=head1 AUTHOR

Toby Inkster, E<lt>tobyink@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010 by Toby Inkster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
