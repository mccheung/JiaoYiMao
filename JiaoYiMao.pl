#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use YAML::Syck qw/LoadFile DumpFile/;
use HTTP::Cookies::Netscape;
use LWP::UserAgent;
use HTML::TreeBuilder;
use Digest::MD5 qw/md5_hex/;

$YAML::Syck::ImplicitTyping = 1;

my $incoming_file = './Incoming.yaml';
my $incoming = LoadFile( $incoming_file );

my $cookie = HTTP::Cookies::Netscape->new(
  file => "xxx.txt",
  autosave => 1,
  hide_cookie2 => 1,
);

my $ua = LWP::UserAgent->new(
  cookie_jar => $cookie,
);

my $url = 'https://www.jiaoyimao.com/message';
my $pages = 0;
my $res = $ua->get( $url );

( $pages ) = $res->content() =~ /共(\d+)页/
  if $res->is_success;

if ( $pages && $pages > 0 ) {
  foreach my $page ( 1..$pages ) {
    my $urls = get_message_urls( $page );
    next unless $urls && @$urls > 0;
    foreach my $m_url ( @$urls ) {
      my $m_url_md5 = md5_hex( $m_url );
      next if exists $incoming->{ $m_url_md5 };

      my $data = get_data( $m_url );
      #print Dumper( $data );
      $incoming->{ $m_url_md5 }->{ diamond } = $data->{ diamond };
      $incoming->{ $m_url_md5 }->{ money } = $data->{ money };
      $incoming->{ $m_url_md5 }->{ url } = $m_url;
      $incoming->{ $m_url_md5 }->{ date } = $data->{ date };
    }
  }
}


DumpFile( $incoming_file, $incoming );

my ( $totals, $diamonds ) = ( 0, 0 );

foreach ( keys $incoming ) {
  $totals += $incoming->{ $_ }->{ money }
    if $incoming->{ $_ }->{ money } > 0;
  $diamonds += $incoming->{ $_ }->{ diamond }
    if $incoming->{ $_ }->{ diamond } > 0;
}
print "\n\nTotal Incoming: $totals\nTotal Diamonds: $diamonds\n\n";

sub get_data {
  my ( $url ) = @_;
  return {} unless $url;
  print "MessageURL: $url\n";

  my $res = $ua->get( $url );
  return {} unless $res->is_success;

  my ( $diamond, $money ) = $res->content =~ m#您的商品【([\d\.]+)钻石】已经成功转账([\d\.]+)元#;
  my ( $date ) = $res->content =~ m#(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})#;
  return {
    diamond => $diamond,
    money => $money,
    date => $date,
  };
}


sub get_message_urls {
  my ( $page ) = @_;
  my $url = "https://www.jiaoyimao.com/message?page=$page&isRead=0";
  print "MessageListURL: $url\n";

  my $res = $ua->get( $url );
  return [] unless $res->is_success;

  my $t = HTML::TreeBuilder->new_from_content( $res->content() );
  my @message = $t->look_down( _tag => 'span', class => 'name' );
  @message = map { $_->look_down( _tag => 'a' ) } @message;
  @message = grep { $_->as_trimmed_text =~ /分润/ } @message;
  # map { print $_->as_trimmed_text . "\n" } @message;
  @message = map { $_->attr( 'href' ) } @message;
  return \@message;
}

