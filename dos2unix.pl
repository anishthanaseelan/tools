#!/usr/contrib/bin/perl
###############################################################################
#
#   File Name:       dos2unix.pl
#   Author:          Anish Thanaseelan.K
#   Date:            03-Nov-2009
#   Purpose:
#   Functions:       Nil
#   Global variable: N/A
#
###############################################################################

$RC = 0;

if ( $#ARGV != 0 )
{
   print  "Invalid Arguments <@ARGV>\n";
   print "Usage : $0 <FileName>\n";
   $RC = 1;
}
else
{
   $Source = $ARGV[0];
   $Dist = "$Source".".back";

   if ( -f "$Source" && -s "$Source" )
   {
      system ( "mv $Source $Dist" );

      if ( open ( SOURCE , "<$Dist" ) )
      {
         if ( open ( DIST , ">$Source" ) )
         {

            while ( <SOURCE> )
            {
               $_ =~ s/\x0a|\x0d//g;
               print DIST "$_\n";
            }
            close ( SOURCE );
            close ( DIST );
         }
         else
         {
            print  "Unable to write $Source \n";
            $RC = 100;
         }
      }
      else
      {
         print  "Unable to read $Dist \n";
         $RC = 100;
      }
   }
}

exit ( $RC );
