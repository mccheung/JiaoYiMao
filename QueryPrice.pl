#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use LWP::UserAgent;
use HTML::TreeBuilder;

my $area = shift;
usage() && exit unless $area;
chomp( $area );

my $url = 'http://www.jiaoyimao.com/g1213-c1417589873316856/s%E5%A5%87%E8%BF%B9' . $area . '%E5%8C%BA.html';


my $ua = LWP::UserAgent->new();

my $resp = $ua->get( $url );
exit unless $resp->is_success;

my $t = HTML::TreeBuilder->new_from_content( $resp->content );
my @lists = $t->look_down( _tag => 'li', name => 'goodsItem' );

my $result = {};
foreach my $list ( @lists ) {
  my $p = $list->look_down( _tag => 'span', class => 'name' );
  if ( $p ) {
    $p = $p->as_trimmed_text;
    #print "$p\n";
    ( $p ) = $p =~ /=([\d\.]+)/;
  }
  $p = '' unless $p;

  my $price = $list->look_down( _tag => 'span', class => 'price' );
  if ( $price ) {
    $price = $price->as_trimmed_text;
  }
  $price = '' unless $price;

  push @{$result->{ $p }}, $price;
}


foreach my $p ( sort { $b <=> $a } keys %$result ) {
  print "比例: $p\t" . join ( ' ', @{ $result->{ $p }} ) . "\n";
}

sub usage {
  print <<EOF
  perl QueryPrice.pl 大区编号 例如:
  perl QueryPrice.pl 846
EOF
}
