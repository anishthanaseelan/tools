#!/bin//perl
##!/usr/contrib/bin/perl
###############################################################################
#
#   File Name:       Align.pl
#   Author:          Anish Thanaseelan.K
#   Date:            09-May-2008
#   Purpose:         To align C source code
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
   $STab = "   ";
   $Tab  = "";
   $Fix = 0;
   $Stmtcont = 0;
   $Opened = 0;

   if ( -f "$Source" && -s "$Source" )
   {
      system ( "mv $Source $Dist" );

      if ( open ( SOURCE , "<$Dist" ) )
      {
         if ( open ( DIST , ">$Source" ) )
         {

            while ( <SOURCE> )
            {
              if ( $_ =~ /^\s+lSqlStmt/ || $_ =~ /^enum/ || $_ =~ /^\s+EXEC SQL FETCH/ )
              {
                 $qryFlag = 1;
                 print DIST "$_";
              }
              elsif ( $qryFlag == 1 &&  $_ =~ /;$/ )
              {
                   $qryFlag = 0;
                   print DIST "$_";
              }
              elsif ( $qryFlag == 1 )
              {
                   print DIST "$_";
              }
              else
              {
               $_ =~ s/\x0a|\x0d//g;
               $_ =~ s/^\s+|\s+$//;

               if ( $_ =~ /^\{/ && $_ =~ /^\}/ )
               {
                  print DIST "$Tab"."$_\n";
                  $Opened = 0;
               }
               elsif ( $_ =~ /^\{/ )
               {
                  print DIST "$Tab"."$_\n";
                  $Tab = $Tab.$STab if ( !$Fix );
                  $Stmtcont = 0;
                  $Opened = 1;
               }
               elsif ( $_ =~ /^\}/ )
               {
                  $Tab =~ s/$STab// if ( !$Fix );
                  print DIST "$Tab"."$_\n";
                  #$Stmtcont = 0 if ( $_ =~ /\;$/ );
                  $Stmtcont = 0;
                  $Opened = 0;
               }
               elsif ( $_ =~ /^\/\*/ && $_ =~ /\*\// )
               {
                  print DIST "$Tab"."$_\n";
                  $Opened = 0;
               }
               elsif ( $_ =~ /\*\// )
               {
                  print DIST "$Tab"."$_\n";
                  $Fix = 0;
                  $Opened = 0;
               }
               elsif ( $_ =~ /\/\*/ )
               {
                  print DIST "$Tab"."$_\n";
                  $Opened = 0;
                  $Fix = 1;
               }
               else
               {
                  if ( $_ !~ /\;$/ && $_ !~ /^\#/ && $_ !~ /^\*/ && $_ !~ /^$/ && !$Stmtcont && !$Fix )
                  {
                     $Stmtcont = 1;
                     $Opened = 0;
                     print DIST "$Tab"."$_\n";
                  }
                  elsif ( $Stmtcont && !$Opened )
                  {
                     if ( $Opened || ( !$Opened && ( $_ =~ /^\*/ || $_ =~ /^\#/ )  ) )
                     {
                        print DIST "$Tab"."$_\n";
                     }
                     elsif ( $Stmtcont )
                     {
                        print DIST "$STab"."$Tab"."$_\n" ;
                     }
                     else
                     {
                        print DIST "$Tab"."$_\n" ;
                     }
                     $Opened = 0;

                     if ( $_ =~ /\;$/ )
                     {
                        $Stmtcont = 0;
                     }
                  }
                  else
                  {
                     print DIST "$Tab"."$_\n";
                     $Opened = 0;
                  }
               }
             }

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
