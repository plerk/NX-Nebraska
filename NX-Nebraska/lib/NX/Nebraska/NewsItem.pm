package NX::Nebraska::NewsItem;

use strict;
use warnings;
use feature qw( :5.10 );
use NX::Ziyal ();
use POSIX ();

sub new
{
  my $ob = shift;
  my $class = ref($ob) || $ob;
  my %args = @_;
  
  my $id = $args{filename};
  $id =~ s!^.*/!!;
  $id =~ s!\.zl$!!;
  
  return bless {
    filename => $args{filename},
    id => $id,
    is_cached => $args{is_cached} // 1,
    c => $args{c},
  }, $class;
}

sub get_news_from_directory
{
  my $class = shift;
  my %args = @_;
  
  return () unless defined $args{dir} && -d $args{dir};
 
  opendir(DIR, $args{dir});
  my @fn_list = readdir DIR;
  closedir DIR;
  
  my @list;
  
  foreach my $fn (@fn_list)
  {
    next unless $fn =~ /^\d+\.zl$/;
    push @list, new NX::Nebraska::NewsItem(
      filename => "$args{dir}/$fn",
      is_cached => $args{is_cached},
      c => $args{c},
    );
  }
  return @list;
}

sub find_by_id
{
  my $class = shift;
  my %args = @_;
  
  foreach my $dirspec (@{ $args{dir_spec} })
  {
    my($dir, $is_cached) = @{ $dirspec };
    next unless defined $dir && -d $dir;
    if(-r "$dir/$args{id}.zl")
    {
      return (new NX::Nebraska::NewsItem(
        filename => "$dir/$args{id}.zl",
        is_cached => $is_cached,
        c => $args{c},
      ));
    }
  }
  return ();
}

sub filename { shift->{filename} }
sub id { shift->{id} }
sub is_cached { shift->{is_cached} }

# Generate a timestamp as easily consumable by a human being.
sub timestr
{
  my $self = shift;
  return lc POSIX::strftime("%e %B %Y %I:%M%p", localtime $self->id);
}

sub _process
{
  my $self = shift;
  my $c = $self->{c};
  
  return $self->{result} if defined $self->{result};
  
  my $cache_key = "news:" . $self->id;
  
  if($self->is_cached)
  {
    my $cached = $c->memd->get($cache_key);
    if(defined $cached)
    {
      $self->{result} = $cached;
      return;
    }
  }

  open(IN, $self->filename);
  my $zl = do { local $/; <IN> };
  close IN;
  
  my $doc = NX::Ziyal::ziyal2html($zl, default => $c->uri_for('/'));
  
  my %result = (
    html => $doc->html,
    title => $doc->title,
    id => $self->id,
    timestr => $self->timestr,
  );
  
  if($self->is_cached)
  {
    $c->memd->set($cache_key => \%result, 60*60);
  }
  
  $self->{result} = \%result;
  return;
}

sub html
{
  my $self = shift;
  $self->_process;
  return $self->{result}->{html};
}

sub title
{
  my $self = shift;
  $self->_process;
  return $self->{result}->{title};
}

1;
