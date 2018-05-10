  #!/usr/contrib/bin/perl
  ###############################################################################
  #
  #   File Name:       CompareDir.pl
  #   Author:          Anish Thanaseelan.K
  #   Date:            02-Jan-2010
  #   Purpose:         To Compare Two Directories
  #   Usage:           perl CompareDir.pl <Dir1> <Dir2>
  #
  ###############################################################################
  use strict;

  #my $Dir1 = "C:\\ccview\\Clear\\Changed";
  #my $Dir2 = "C:\\ccview\\Clear\\Original";

  die "Usage Error : perl CompareDir.pl <Dir1> <Dir2>" if ( scalar ( @ARGV != 2 ) );

  my $Dir1 = "$ARGV[0]";
  my $Dir2 = "$ARGV[1]";

  print "Comparing Dirs [$Dir1] [$Dir2] \n";

  my $HashRef = undef;
  my $ArrayRef1 = undef;
  my $ArrayRef2 = undef;
  my $File = "";
  my @Files = ();
  my $lRc = 0;
  my $JustFile = "";
  my @Dir1Files = ();
  my @Dir2Files = ();

  ( $lRc,$ArrayRef1 ) = &ExploreDir ($Dir1);
  @Dir1Files = @Files if ( $lRc == 0 ) ;
  @Files = ();

  ( $lRc,$ArrayRef2) = &ExploreDir ($Dir2) if ( $lRc == 0 );
  @Dir2Files = @Files if ( $lRc == 0 ) ;
  @Files = ();

  ( $lRc , $HashRef ) = &FindDiff( \@Dir1Files , \@Dir2Files) if ( $lRc == 0 );

  if ( $lRc == 0 )
  {
     foreach $File ( @Dir2Files )
     {
        $JustFile = $File;
        $JustFile =~  s/\Q$Dir2\E//;
        #print "<DEBUG>$HashRef->{$JustFile} \n";
        $HashRef->{$JustFile} = "Found Only in $Dir2" if ( ! defined $HashRef->{$JustFile} );
     }
  }
  if ( open ( RPT , ">Report.csv" ) )
  {
     foreach $File ( keys %{$HashRef} )
     {
        print RPT "$File,$HashRef->{$File}\n";
     }
     close ( RPT);
     system ( "notepad Report.csv" );
  }
  else
  {
     print "<ERROR> Unable to open Report.csv \n";
     $lRc = 1;
  }


  exit ( $lRc );

  sub ExploreDir()
  {
     my $dir = shift || die "Must be passed a directory.\n";


         opendir(FH, "$dir") || die "Can not open <$dir>\n";
         my @files = grep { /^[^\.].*$/ } readdir(FH);
         closedir ( FH );

         foreach my $file ( @files )
     {
        if ((-d "$dir\\$file"))
        {
           &ExploreDir("$dir\\$file");
           next;
        }
        else
        {
           chomp($file);
           #print "Exploring $dir\\$file \n";
           push ( @Files , "$dir\\$file" );
        }

     }

         return ( $lRc );
  }


sub FindDiff ()
  {
     my $ArrRef1 = shift;
     my $ArrRef2 = shift;
     my @Files1 = @{$ArrRef1};
     my @Files2 = @{$ArrRef2};
     my $File1 = "";
     my $File2 = "";
     my %DiffList = ();
     my ( $JustFile1 , $JustFile2 ) = "";
     my ( $lRc , $tRc ) = 0;
     foreach $File1 ( @Files1 )
     {
        $JustFile1 = $File1;
        $JustFile1 =~  s/\Q$Dir1\E//;
        #print "Finding Diff between $JustFile1 [$File1] [$Dir1][$Dir2]\n";
        foreach $File2 ( @Files2 )
        {
           #print "Finding Diff between $File1 $File2 \n";

           $JustFile2 = $File2;
           $JustFile2 =~  s/\Q$Dir2\E//;
           #print "Finding Diff between $JustFile1 $JustFile2 [$File2] \n";
           if ( "$JustFile1" eq "$JustFile2" )
           {
              $tRc = &DiffFile( $File1 , $File2 );
              $lRc = $tRc if ( $tRc == 1 );
              $DiffList{$JustFile1} = "Different" if ( $tRc == 2 );
              $DiffList{$JustFile1} = "Identical" if ( $tRc == 0 );
              last;
           }
        }
        $DiffList{$JustFile1} = "Found Only in $Dir1" if ( ! defined $DiffList{$JustFile1} );
     }
     return ( $lRc , \%DiffList );
  }
  sub DiffFile()
  {

     my $File1 = shift;
     my $File2 = shift;

     my ( $lRc, $i ) = 0;
     my ( $FileRef1 , $FileRef2 ) = undef;
     my ( $Line1 , $Line2   ) = "";

     ( $lRc , $FileRef1 ) = &CopyFile ( $File1 );

     ( $lRc , $FileRef2 ) = &CopyFile ( $File2 ) if ( $lRc == 0 );
     if ( $lRc == 0 )
     {
        for( $i =0 ,$i< scalar ( @{$FileRef1} ) , $i++ )
        {
           $Line1 = $FileRef1->[$i];
           $Line2 = $FileRef2->[$i];

           $FileRef1->[$i] =~ s/\x0a|\x0d//g;
           $FileRef1->[$i] =~ s/^\s+|\s+$//;
           $FileRef2->[$i] =~ s/\x0a|\x0d//g;
           $FileRef2->[$i] =~ s/^\s+|\s+$//;
           if ( $FileRef1->[$i] ne $FileRef2->[$i] )
           {
              #print "[$FileRef1->[$i]][$FileRef2->[$i]] \n";
              $lRc = 2;
              last;
           }
        }
     }
     return ( $lRc );
  }

  sub CopyFile()
  {
     my $File = shift;
     my @File = ();
     if ( open ( FILE , "<$File" ) )
     {
        @File = <FILE>;
     }
     else
     {
        $lRc = 1;
        print "unable to open $File\n";
     }
     return ( $lRc , \@File );
  }
