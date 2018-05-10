use Clear;
use File::Path;

my $lRc = 0;
my $Label = '"CODE_REVIEW_01182010"';
my $FileName = '';
my $Dir =  "C:\\ccview\\IDC_Release\\GLS_VOB\\GLS_Server\\Source\\Server\\" ;

#print "$Dir\n";

if ( open ( LstH , "<FileList.lst" ) )
{
        print "Creating Lable type $Label ...... \n";
        if ( 0 == &Clear::CreateLabel ( $Label , $Dir ) )
        {
                while ( <LstH> )
                {
                        $_ =~ s/^\s+|\s+$//g;
                        $_ =~ s/x0a|x0d//g;
                        $File = $_;
                        $FileName = "$Dir"."$File";
                        $FileCnt++;
                        print "Processing File # $FileCnt : $FileName \n";

                        if ( -f "$FileName"  )
                        {
                                print "Attaching $FileName with label $Label ....\n";
                                $lRc = &Clear::PutLabel ( $FileName, $Label);
                        }
                        else
                        {
                                print "<ERROR>Not A File : $FileName \n";
                        }

                }
        }
        else
        {
                print "Label Creating Failed....\n";
        }
        close ( LstH );
}
else
{
        print "<ERROR>unable to open FileList.lst \n";
}
