#!/opt/standard_perl/perl/bin/perl
#START######################################################
#
# Version :  2.0
#
# Filename: Align2.pl
#
# Author  : Anish Thanaseelan
#
# Date    : 21/01/2009
#
# Purpose : To align a source code
#
############################################################
#                       Change History
############################################################
#
# Author       Change Desc.              Date          Ver
#
#########################################################END

use IniConf;
use File::Copy;
use File::Path;

my $gRc = 0;
my %gIniEntry = ();
my @gSourceFiles = ();
my $gIndentFlag = 0; # For Indentation Handling
my $gAlignChar = '';
my $gSkipFlag = 0;  # For Align Exception Handling
my $gIniFile ='';

#### Checking Usage #####

print "Running Align2.pl \n";

if ( scalar ( @ARGV ) == 1 )
{
   if ( -f $ARGV[0] && $ARGV[0] =~ /\.ini$/i )
   {
        $gIniFile = $ARGV[0];
   }
}
else
{
        print "Please enter the Ini File Path \n";
        $gIniFile = <STDIN>;
        $gIniFile =~  s/\x0a|\x0d//g;
        if (! -f $gIniFile || $gIniFile !~ /\.ini$/i)
        {
                print "Sorry !! It's a invalid Ini file....\n";
                $gIniFile = '';
                $gRc = 1;
   }
}
if ( $gRc == 0 )
{
        $gRc = &ReadIni($gIniFile);
        $gRc = &GetFiles() if ( $gRc == 0 );
        $gRc = &ProcessFiles() if ( $gRc == 0 );

}

print "\n Bye  :-) \n";

sub ReadIni()
{
        my $Rc = 0;
        my $IniFile = $_[0];

        print "Reading Ini File $IniFile \n";

        my $Cfg = IniConf->new( -file => $IniFile );

        if ( $Cfg )
        {
                # reading ini entries

                @IniEntries=$Cfg->Sections;

                if ( grep(/^GENERAL$/, @IniEntries ) && grep(/^ALIGN$/, @IniEntries ) && grep(/^EXCEPTION$/, @IniEntries ))
                {
                        @Sections=( "GENERAL" , "ALIGN" , "EXCEPTION" ) ;

                        foreach $sec ( @Sections )
                        {
                                foreach $par ( $Cfg->Parameters($sec) )
                                {
                                        foreach $var ( $Cfg->val($sec , $par) )
                                        {
                                           if ( $var !~ /^$/ )
                                           {
                                                        $gIniEntry{uc($par)}=$var;
                                                }
                                                else
                                                {
                                                        if ( $par =~ /AlignDir/i )
                                                        {
                                                                print " Please enter the Align Dir \n ";

                                                                $gIniEntry{uc($par)} = <STDIN>;
                                                                $gIniEntry{uc($par)} =~  s/\x0a|\x0d//g;
                                                                if (! -d $gIniEntry{uc($par)} )
                                                                {
                                                                        print "Sorry ! .. That's a invalid Dir..... <$gIniEntry{uc($par)}>\n";
                                                                        $Rc = 1;
                                                                }
                                                        }
                                                        elsif ( $par =~ /BackupDir/i )
                                                        {
                                                                print "You Didn't give a Backup dir... \n";
                                                                $gIniEntry{uc($par)} = "";
                                                        }
                                                        else
                                                        {
                                                                print "Parameter <$par> is empty, please compleate the Ini\n";
                                                                $Rc = 1;
                                                        }
                                                        break if ( $Rc != 0 );
                                                }
                                         }
                                         break if ( $Rc != 0 );
                                }
                                break if ( $Rc != 0 );
                        }

                        if ( $Rc == 0 )
                        {

                                if ( $gIniEntry{BACKUPDIR} =~ /^$/ )
                                {

                                        $gIniEntry{BACKUPDIR} = "$gIniEntry{ALIGNDIR}"."Backup"."\\" ; ## HAVE TO BE CHANGE
                                        print "The BackupDir would be $gIniEntry{BACKUPDIR} \n";
                                }

                                if (! -d $gIniEntry{BACKUPDIR} )
                                {
                                        print "Backup Dir not found, Creating....\n";
                                        mkdir ( "$gIniEntry{BACKUPDIR}", 0700 );

                                        if (! -d $gIniEntry{BACKUPDIR} )
                                        {
                                                print "Backup Dir Creation Failed \n";
                                                $Rc = 1;
                                        }
                                }

                                if ( $gIniEntry{STARTEXCEPTION} !~ /^$/ )
                                {
                                        @Exceptions = split (   /\|/ , $gIniEntry{STARTEXCEPTION} );

                                        foreach $Exce ( @Exceptions )
                                        {
                                                $ExceStr = $ExceStr . "\Q$Exce\E" . "|";
                                        }
                                        chop ( $ExceStr );

                                        $gIniEntry{STARTEXCEPTION} = $ExceStr;
                                }
                                if ( $gIniEntry{SINGLELINECOMMENTCHAR} !~ /^$/  )
                                {

                                        @CommentChar = split (  /\|/ , $gIniEntry{SINGLELINECOMMENTCHAR} );

                                        foreach $Char ( @CommentChar )
                                        {
                                                $CommentStr = $CommentStr . "\Q$Char\E" . "|";
                                        }
                                        chop ( $CommentStr );

                                        $gIniEntry{SINGLELINECOMMENTCHAR} = $CommentStr;
                                }

                                $gIniEntry{ALIGNCHAR} =~ s/\|//g;
                                $gIniEntry{INTENDCHAR} =~ s/\|//g;

                                $gIniEntry{FILEEXT} = '*' if ( $gIniEntry{FILEEXT} =~ /^$/ );
                        }
                }
                else
                {
                        print "<ERROR>Some section(s) are missing in the Ini \n";
                        $Rc = 1;
                }
        }
        else
        {
                print "Problem in reading ini file: $IniFile \n";
                $Rc = 1;
        }
        return ( $Rc );
}
sub GetFiles()
{
        $Rc = 0;

        print "Gathering the File list ..... \n";

        if ( opendir( SourceDir, $gIniEntry{ALIGNDIR} )  )
        {
                @gSourceFiles = grep( /^*\.($gIniEntry{FILEEXT})$/i , sort( readdir( SourceDir ) ) );
                closedir ( SourceDir );
                print "The File List : \n @gSourceFiles \n";
        }
        else
        {
                print "Unable to Open $gIniEntry{ALIIGNDIR} \n";
                $Rc = 0;
        }


        return ( $Rc );
}
sub ProcessFiles()
{
        my $Rc = 0;

        if ( scalar ( @gSourceFiles ) > 0 )
        {
                print "Processing Source Files... \n";

                foreach $File ( @gSourceFiles )
                {
                        $Rc = &TakeBackup($File);

                        $Rc = &Align($File) if ( $Rc == 0 );
                }
        }
        else
        {
                print "There are no Files to Align.. \n";
        }

        return ( $Rc );

}

sub TakeBackup()
{

        my $Rc = 0;
        print "Taking Backup..";

        if ( ! move ( "$gIniEntry{ALIGNDIR}"."$_[0]" , "$gIniEntry{BACKUPDIR}"."$_[0]" ) )
        {
                $Rc = 1;
                print " Failed\n";
        }
        else
        {
                print " Done\n";
        }

        return ( $Rc );
}
sub Align()
{
        my $Rc = 0;
        print "Aligning ..";

        $Source = "$gIniEntry{BACKUPDIR}"."$_[0]";
        $Dist = "$gIniEntry{ALIGNDIR}"."$_[0]";

        if ( -f "$Source" && -s "$Source" )
        {
                if ( open ( SOURCE , "<$Source" ) )
                {
                        if ( open ( DIST , ">$Dist" ) )
                        {
                                while ( <SOURCE> )
                                {
                                        $Line = $_;

                                        $Line =~ s/\x0a|\x0d//g;
                                        $Line =~ s/^\s+|\s+$//;
                                        if ( $Line !~ /^$/ )
                                        {
                                                if ( ! &Skipline ($Line) )
                                                {
                                                        $Line = &AlignLine($Line);
                                                        print "<ALIGNED>$Line\n";
                                                        print DIST "$Line\n";
                                                }
                                                else
                                                {
                                                        print "<skiped>$_";
                                                        print DIST "$_";
                                                }
                                        }
                                        else
                                        {
                                                print DIST "\n";
                                        }
                                }

                                close (DIST);
                                print " Done\n";
                        }
                        else
                        {
                                print "Unable to open $_[0] for writing \n";
                                $Rc = 1;
                        }
                        close (SOURCE);
                }
                else
                {
                        print "Unable to open $_[0] for Reading \n";
                        $Rc = 1;
                }
        }
        else
        {
                print "Invalid File ...<$Source>\n";
                $Rc =1;
        }
        return ( $Rc );
}


sub Skipline()
{
        my $Line = $_[0];
        my $SkipFlag = 0;
        if ( $Line =~ /^($gIniEntry{SINGLELINECOMMENTCHAR})/ ||
                        ( $Line =~ /^\Q$gIniEntry{COMMENTSTARTCHAR}\E/  &&
                                $Line =~ /\Q$gIniEntry{COMMENTENDCHAR}\E$/ ) && $gSkipFlag == 0 )
        {
                $SkipFlag = 1;
        }

        ## Dont Check Exception on a commented Line #####

        ## Comment Inside Commect is not Handled ##

        elsif ( $Line =~ /^\Q$gIniEntry{COMMENTSTARTCHAR}\E/  )
        {
                $gCommentFlag = 1;
                $gSkipFlag = 1;
                $SkipFlag = 1;
        }
        elsif ( $Line =~ /\Q$gIniEntry{COMMENTENDCHAR}\E$/ )
        {
                $gCommentFlag = 0;
                $gSkipFlag = 0;
                $SkipFlag = 1; # No need to skip current line #

        }
        elsif ( $gCommentFlag == 1 )
        {
                $gSkipFlag = 1;
                $SkipFlag = 1;
        }
        elsif ( $gCommentFlag == 0 )
        {

                if ( $Line =~ /^($gIniEntry{STARTEXCEPTION})/ )
                {

                        $gSkipFlag = 1;
                        $SkipFlag = 1;
                }
                elsif ( $Line =~ /($gIniEntry{STOPEXCEPTION})$/ && $gSkipFlag == 1)
                {

                        $gSkipFlag = 0;
                        $SkipFlag = 1;
                }
                else
                {
                        $SkipFlag = $gSkipFlag;
                }
        }
        return $SkipFlag ;
}



sub AlignLine()
{
        my $Line = $_[0];

        if ( $Line =~ /^\{/  && $Line =~ /\}$/ )
        {
                $Line = $gAlignChar . $Line;
        }
        elsif ( $Line =~ /^\{/ || $Line =~ /\{$/ )
        {
                $Line = $gAlignChar . $Line;
                $gAlignChar .= $gIniEntry{ALIGNCHAR};
        }
        elsif ( $Line =~ /\}$/  && !$gSkipFlag )
        {
                $gAlignChar =~ s/$gIniEntry{ALIGNCHAR}//;
                $Line = $gAlignChar . $Line;
        }
        else
        {
                if ( &Intent($Line) )
                {
                        $Line = $gAlignChar .$gIniEntry{INTENDCHAR}. $Line;
                }
                else
                {
                        $Line = $gAlignChar . $Line;
                }
        }
        return $Line;
}
sub Intent()
{
        my $Line = $_[0];
        my $Intent = 0;

        if( $gIndentFlag == 1 )
        {
                $Intent = 1;
                print "<DENIG9> $Line \n";
        }

        if ( $Line =~ /\;$/ && $gIndentFlag == 1)
        {
                $gIndentFlag = 0;
                $Intent = 1;

                print "<DENIG8> $Line \n";
        }
        elsif ( $Line !~ /\;$/ && $gCommentFlag == 0 && $gIndentFlag == 0 )
        {
                $gIndentFlag = 1;
                $Intent =0;
                print "<DENIG8> $Line \n";

        }
        elsif ( $Line !~ /\;$/ && $gCommentFlag == 0 && $gIndentFlag == 1 )
        {
                        $Intent =1;
                        print "<DENIG10> $Line \n";
        }

        return ( $Intent );
}
