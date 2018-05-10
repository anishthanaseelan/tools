#!/opt/standard_perl/perl/bin/perl -w
###############################################################################
#
#   File Name:       FindLOC.pl
#   Author:          Anish Thanaseelan.K
#   Purpose:
#   Usage:           perl FindLOC.pl <Dir1>
#
###############################################################################
use strict;

die "Usage Error : perl $0 <Dir1>" if ( scalar ( @ARGV != 1 ) );

my $Dir1 = "$ARGV[0]";

my $HashRef = undef;
my $ArrayRef1 = undef;

my $File = "";
my @Files = ();
my $lRc = 0;
my $JustFile = "";
my @Dir1Files = ();
my $Filecnt = 0;
my $TotFilecnt = 0;


( $lRc,$ArrayRef1 ) = &ExploreDir ($Dir1);
@Dir1Files = @Files if ( $lRc == 0 ) ;
@Files = ();
unlink ( "Report.csv" )if ( $lRc == 0 );
print "Processing Dir [$Dir1] \n";

$TotFilecnt = scalar ( @Dir1Files );

foreach $File ( @Dir1Files )
{
   $Filecnt++;
   print "$Filecnt of $TotFilecnt ";
   $lRc = &FindLOC( $File  ) if ( $lRc == 0 );

}

system ( "cat Report.csv");
exit ( $lRc );
sub ExploreDir()
{
     my $dir = shift || die "Must be passed a directory.\n";
     opendir(FH, "$dir") || die "Can not open <$dir>\n";
     my @files = grep { /^[^\.].*$/ } readdir(FH);
     closedir ( FH );

     foreach my $file ( @files )
     {
        if ((-d "$dir\/$file"))
        {
           &ExploreDir("$dir\/$file");
           next;
        }
        else
        {
           chomp($file);
           push ( @Files , "$dir\/$file" ) if ($file =~ m/\.ec$/ || $file =~ m/\.c$/ ) ;
        }
     }
     return ( $lRc );
}
sub FindLOC()
{

   my $File1 = shift;

   print "Processing File $File1 \n";

   my $RptLine = "";
   my @Function = ();
   my $BlockCount = 0;
   my $SourceCount = 0;
   my $CommentCount = 0;
   my $BlankCount = 0;
   my $FunctionName ="";

   my ( $lRc , $FileRef1 ) = &CopyFile ( $File1 );

   die "Unable to Open Rpt " if ( ! open ( RPT ,">>Report.csv" ) );

   print RPT "File Name,Function,SourceCount,CommentCount,BlankCount\n" if ( -z "Report.csv" );

   for ( my $i =0 ; $i < scalar ( @{$FileRef1} );$i++ )
   {
         $BlockCount++ if ( $FileRef1->[$i] =~ /\{/ );
         $BlockCount-- if ( $FileRef1->[$i] =~ /\}/ );
         @Function = () if ( $BlockCount == 1 && $FileRef1->[$i] =~ /\{/ );

         if ( $BlockCount == 0 && $FileRef1->[$i] =~ /\}/ )
         {
           ( $SourceCount , $CommentCount , $BlankCount ) = 0;

           ( $SourceCount , $CommentCount , $BlankCount )= &CountLine ( \@Function) ;

            print RPT "\'$File1,\'$FunctionName,$SourceCount,$CommentCount,$BlankCount\n" if ($FunctionName !~ /^$/ && $SourceCount > 0 ) ;

         }
         elsif ( $BlockCount == 0 )
         {
            if ( $FileRef1->[$i] =~ /^(\s*)(int|void|char)*(\s*)(\w+)(\s*)(\()/ && $FileRef1->[$i] !~ /\;/ )
            {
               $FunctionName = $4;
            }
         }
         if ( $BlockCount > 0 )
         {
            push ( @Function , "$FileRef1->[$i]" );

         }
   }
   close ( RPT );
   return ( $lRc );
}
sub CountLine ()
{
   my $Function = shift;
   my $BlankCount = 0;
   my $SourceCount = 0;
   my $CommentCount = 0;
   my $ChangeStarted = 0;
   my $ComtCnt = 0;
   my $line = "";
   my $StartPattern =
   my $EndPattern =

   foreach $line (  @{$Function} )
   {
      $line =~ s/\x0a|\x0d//g;
      $line =~ s/^\s+|\s+$//g;

      #print "<LINE> $line \n";

      if ( $line =~ /$StartPattern/ )
      {
          $ChangeStarted = 1;
      }
      elsif ( $line =~ /$EndPattern/ )
      {
          $ChangeStarted = 0;
      }

      if ( $line =~ /^$/ )
      {
          $BlankCount++;
          #print "<BLANK> $line \n";
          next;
      }
      if ( ! $ChangeStarted )
      {
          next;
      }

      $CommentCount++;

      # Skip Commented Lines

      if ( $line =~ /^\/\//  )
      {
           next ;
      }
      elsif ( $line =~ /^\/\*/) #Commented Line Start
      {
         #print "Commented Line Start<$line> \n";

         if ( $line =~ /\*\/$/ ) #Comment End in the same line
         {
            #print "End in the same line<$line> \n";
            next;
         }
         else  # Comment will end in the coming lines
         {
            $ComtCnt = 1;
            next;
         }
      }
      elsif ( $line =~ /\*\/$/ && $ComtCnt == 1  ) #Found a Comment end
      {
         #print "Found a Comment end $line\n";
         $ComtCnt = 0;
         next;
      }
      elsif ( $ComtCnt == 1 ) # Comment Continues
      {
         #print "Comment Continues $line\n";
         next;
      }
      else
      {
         if ( $line =~ /^(.*)(\s*\/\/\s*)(.*)$/ )
         {

               $line = $1;

         }

         $SourceCount++;
         $CommentCount--;
      }
   }

   return ( $SourceCount, $CommentCount , $BlankCount );
}

sub CopyFile()
{
   my $File = shift;
   my @File = ();
   if ( open ( FILE , "<$File" ) )
   {
      @File = <FILE>;
      close ( FILE );
   }
   else
   {
      $lRc = 1;
      print "<ERROR>unable to open $File\n";
   }
   return ( $lRc , \@File );
}
