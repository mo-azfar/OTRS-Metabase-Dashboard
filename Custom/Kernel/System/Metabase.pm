# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --API FOR GENERATE METABASE DASHBOARD WEB TOKEN
package Kernel::System::Metabase;

use strict;
use warnings;
use JSON;
use JSON::WebToken; #yum install -y perl-JSON-WebToken

our @ObjectDependencies = (
    'Kernel::Config',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=cut
		
		my $URL = $Self->GenerateTokenURL(
                MetabaseURL => $ConfigObjectDashboard->{'MetabaseURL'},
				SecretKey    => $ConfigObjectDashboard->{'SecretKey'},
				DashboardID  => int($ConfigObjectDashboard->{'DashboardID'}),
				MinutesExpired      => $ConfigObjectDashboard->{'MinutesExpired'},
				HideParam      => \@TotalParam,
		);

=cut

sub GenerateTokenURL {
	my ( $Self, %Param ) = @_;
	
	# check for needed stuff
    for my $Needed (qw(MetabaseURL SecretKey DashboardID MinutesExpired )) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Missing parameter $Needed!",
            );
            return;
        }
    }

	my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
	my $Epoch = $DateTimeObject->ToEpoch();

	my $jwt = JSON::WebToken->encode({
		resource => {'dashboard' => $Param{DashboardID} },
		params => { @{$Param{HideParam}} },
		exp => $Epoch + (60 * $Param{MinutesExpired}) ,
		$Param{MetabaseURL} => JSON::true,
	}, $Param{SecretKey});
	
	my $NewURL = $Param{MetabaseURL}."/embed/dashboard/".$jwt."#theme=night&bordered=true&titled=true";

	return $NewURL;
}

1;

