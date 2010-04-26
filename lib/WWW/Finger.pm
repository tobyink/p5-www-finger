package WWW::Finger;

use strict;
use 5.008;

use Carp;
our @Modules;

our $VERSION = '0.09';

BEGIN
{
	@Modules = ();
	eval "use WWW::Finger::Fingerpoint;";
	carp "Could not load Fingerpoint implementation ($@)" if $@;
	eval "use WWW::Finger::Webfinger;";
	carp "Could not load Webfinger implementation ($@)" if $@;
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

sub import
{
	my $class = shift;
	foreach my $implementation (@_)
	{
		my $module = $implementation;
		$module =~ s/^\+/WWW::Finger::/;
		eval "use $module;";
		carp $@ if $@;
	}
}

sub name     { return qw() if wantarray; return undef; }
sub mbox     { return qw() if wantarray; return undef; }
sub key      { return qw() if wantarray; return undef; }
sub image    { return qw() if wantarray; return undef; }
sub homepage { return qw() if wantarray; return undef; }
sub weblog   { return qw() if wantarray; return undef; }
sub endpoint { return undef; }
sub webid    { return undef; }
sub graph    { return undef; }

1;

__END__

=head1 NAME

WWW::Finger - get useful data from e-mail addresses

=head1 VERSION

0.09

=head1 SYNOPSIS

  use WWW::Finger;
  my $finger = WWW::Finger->new("joe@example.com");
  if (defined $finger)
  {
    print $finger->name . "\n";
  }

=head1 DESCRIPTION

This module is I<not> an implementation of the finger protocol (RFC 1288). Use
Net::Finger for that. Instead it is a set of implementations of I<other> methods
for getting information from an e-mail address, or e-mail-like identifier. This package
includes four such implementations, and it's pretty easy to create your own
additional implementations:

=over 8

=item * WebFinger

=item * Fingerpoint

=item * cpan.org scraper (for user@cpan.org)

=item * Unnamed finger protocol described on bitworking.org

=back

Only the first two implementations are enabled by default. See
"IMPLEMENTATIONS" on how to enable others, and for more details.

=head2 Constructor

=over 8

=item * C<new>

  $finger = WWW::Finger->new($identifier);

Creates a WWW::Finger object for a particular identifier. Will return undef
if no implemetation is able to handle the identifier

=back

=head2 Object Methods

Any of these methods can return undef if the appropriate information
is not available. The C<name>, C<mbox>, C<homepage>, C<weblog>,
C<image> and C<key> methods work in both scalar and list context.
Depending on which implementation was used by C<WWW::Finger::new>,
the object may also have additional methods. Consult the
documentation of the various implementations for details.

=over 8

=item C<name>

The person's name (or handle/nickname).

=item C<mbox>

The person's e-mail address (including "mailto:").

=item C<homepage>

The person's personal homepage.

=item C<weblog>

The person's blog. (There may be some overlap with C<homepage>.)

=item C<image>

An avatar, photo or other image depicting the person.

=item C<key>

The URL of the person's GPG/PGP public key.

=item C<webid>

A URI uniquely identifying the person. See L<http://esw.w3.org/topic/WebID>.

=item C<endpoint>

A SPARQL Protocol endpoint which may provide additional data about the person.
(See L<RDF::Query::Client>.)

=item C<graph>

An RDF::Trine::Model object holding data about the person. (See L<RDF::Trine>.)

=back

=head1 IMPLEMENTATIONS

=head2 Loading Additional Implementations

When importing this package ("use WWW::Finger") you can pass it
a list of additional finger implementations to load. For example:

  use WWW::Finger qw(WWW::Finger::CPAN MyCorp::Finger);

For packages which start with "WWW::Finger::" there is a special
abbreviation:

  use WWW::Finger qw(+CPAN MyCorp::Finger);

Assuming the finger implementations are written correctly,
WWW::Finger->new should just notice they exist and use them
when appropriate.

The WebFinger and Fingerpoint implementations are loaded by
default.

To load additional implementations later on (after you've
already "used" WWW::Finger) you can call the import method:

  WWW::Finger->import(qw(+Foo +Bar MyCorp::Baz));

There's no official method of removing an already-imported
implementation, but if you really need to, try playing around
with the C<@WWW::Finger::Modules> array.

=head2 Calling an Implementation Specifically

If you need to call a particular implementation specifically,
that should be fairly simple:

  use WWW::Finger::WebFinger;
  my $finger = WWW::Finger::WebFinger->new("joe@example.com");
  if (defined $finger)
  {
    print $finger->name . "\n";
  }

=head2 Writing Your Own Implementation

Use this stub:

  package WWW::Finger::Example;
  
  use strict;
  use WWW::Finger;
  use URI;
  
  our @ISA = qw(WWW::Finger);
  our $VERSION = '0.01';
  
  BEGIN { push @WWW::Finger::Modules, __PACKAGE__; }
  
  sub new
  {
    my ($class, $identifier) = @_;
    my $self = {};
    
    # Canonicalise the identifier. You don't have to use
    # "mailto:"; other URI schemes are allowable.
    $identifier = "mailto:$identifier"
      unless $identifier =~ /^[a-z0-9\.\-\+]+:/i;

    # Check whether this package can get useful info
    # from $identifier. If not, then return undef.
    if ('check things here')
    {
      return undef;
    }
    
    $self->{'ident'} = URI->new($identifier);
    bless $self, $class;
  }
  
  # Override WWW::Finger methods like 'name', 'mbox', etc.
  # Feel free to provide additional methods too.
  
  1;

=head1 SEE ALSO

L<Net::Finger>.

L<http://code.google.com/p/webfinger/>.

L<http://buzzword.org.uk/2009/fingerpoint/spec>.

L<http://www.perlrdf.org/>.

L<fingerw>.

=head1 AUTHOR

Toby Inkster, E<lt>tobyink@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010 by Toby Inkster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

