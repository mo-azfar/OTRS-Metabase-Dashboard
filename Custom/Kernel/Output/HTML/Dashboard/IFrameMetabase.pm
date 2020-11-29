# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
#for metabase dashboard
#28112020 - add support for hide mulitple metabase filter

package Kernel::Output::HTML::Dashboard::IFrameMetabase;

use strict;
use warnings;

# prevent 'Used once' warning
use Kernel::System::ObjectManager;

use JSON;
use JSON::WebToken; #yum install -y perl-JSON-WebToken

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get needed parameters
    for my $Needed (qw(Config Name UserID)) {
        die "Got no $Needed!" if ( !$Self->{$Needed} );
    }

    return $Self;
}

sub Preferences {
    my ( $Self, %Param ) = @_;

    return;
}

sub Config {
    my ( $Self, %Param ) = @_;

    return (
        %{ $Self->{Config} }
    );
}

sub Run {
    my ( $Self, %Param ) = @_;

    # quote Title attribute, it will be used as name="" parameter of the iframe
    my $Title = $Self->{Config}->{Title} || '';
    $Title =~ s/\s/_/smx;
	
	my $MetabaseURL = $Self->{Config}->{'MetabaseURL'};
	my $SecretKey = $Self->{Config}->{'SecretKey'};
	my $DashboardID = int($Self->{Config}->{'DashboardID'});

	my $HideParam = $Self->{Config}->{'HideParam'};
	
	#to support multiple parameter send to metabase. Separator ; 
	my @TotalParam;
	my @SplitParam = split /;/, $HideParam;
	foreach my $NewParam ( @SplitParam )
	{
		my ($ParamKey, $ParamValue) = split /=/, $NewParam;
		$ParamValue = $Self->{$ParamValue};
		#$Self->{UserFullname}
		#$Self->{UserLogin}
		push @TotalParam, $ParamKey => $ParamValue; 
	}
	
	my $MinutesExpired = int($Self->{Config}->{'MinutesExpired'});
	my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
	my $Epoch = $DateTimeObject->ToEpoch();

	my $jwt = JSON::WebToken->encode({
		resource => {'dashboard' => $DashboardID },
		params => { @TotalParam },
		exp => $Epoch + (60 * $MinutesExpired) ,
		$MetabaseURL => JSON::true,
	}, $SecretKey);
	
	my $NewURL = $MetabaseURL."/embed/dashboard/".$jwt."#theme=night&bordered=true&titled=true";	
	$Self->{Config}->{'URL'} = $NewURL;

    my $Content = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Output(
        TemplateFile => 'AgentDashboardIFrame',
        Data         => {
            %{ $Self->{Config} },
            Title => $Title,
        },
    );

    return $Content;
}

1;
