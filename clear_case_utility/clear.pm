package Clear;
use Cwd;

sub CreateLabel()
{
        my $lRc = 0;
        my $Path = getcwd();
        my $Label = shift;
        my $VOBDir = shift;
        chdir ( $VOBDir );
        $lRc = system ( "cleartool mklbtype -rep -pbranch -nc $Label " );
        #$lRc = system ( "cleartool mklbtype -pbranch -nc $Label " );
        chdir ( $Path );
        return $lRc;
}

sub ApplyLable()
{
        my $File = shift;

        my( $lRc , $PrevLable ) = ExtractLable ("$File" );

        if ( $PrevLable !~ /^$/ )
        {

                $lRc = PutLabel($PrevLable , "$File" );
        }
        else
        {
                $lRc = PutLabel("CODE_REVIEW_11302009" , "File" );
        }
        return ( $lRc )

}

sub PutLabel()
{
        my $lRc = 0;
        my $File = shift;
        my $Label = shift;
        $lRc = system ( "cleartool mklabel -rep $Label $File" );
        return $lRc;
}
sub Checkin()
{
        my $lRc = 0;
        my $File = shift;
        $lRc = system ( "cleartool ci -nc $File" );
        return $lRc;
}
sub Checkout()
{
        my $lRc = 0;
        my  ( $Comment,$File )  = @_;
        $lRc = system ( "cleartool co -c $Comment -res $File" );
        return $lRc;
}

sub RevCheckout()
{
        my $lRc = 0;
        my  $File  = shift;
        $lRc = system ( "cleartool uncheckout -rm $File" );
        return $lRc;
}

sub ExtractLable()
{
        my $lRc = 0;
        my $File = shift;
        my $Lable = "";

        $lRc = system ( "cleartool lshistory $File > 1.tmp" );
        if ( 0 == $lRc )
        {
                if ( open ( TmpH , "<1.tmp" ) )
                {
                        while ( <TmpH> )
                        {
                                if ( $_ =~ /CODE_REVIEW/ )
                                {
                                        $_ =~ /^(.*)(CODE_REVIEW_\d+)(.*)$/;
                                        $Lable = $2 ;
                                        last;
                                }
                        }
                        close ( TmpH);
                }
                else
                {
                        print "Unable to create the Temp File \n";
                }
        }
        system ( "del 1.tmp");
        return ( $lRc , $Lable );
}
sub GetCCDiff()
{
        my $lRc =0;
        my $File1 = shift;
        my $File2 = shift;
        my $OutRef = shift;
        @$OutRef = ();

        $lRc = system ( "cleartool diff -col 150 -options \"-quiet -b\" $File1 $File2 > 1.tmp" );

        if ( $lRc )
        {
                if ( open ( TmpH , "<1.tmp" ) )
                {
                        @$OutRef = <TmpH>;
                        #print "        @$OutRef \n";
                        close (TmpH);
                        $lRc = 0;
                        #unlink ( "1.tmp" );
                }
                else
                {
                        print "Unable to create the Temp File \n";
                        $lRc = 1;
                }
        }

        return ( $lRc );
}
1;
