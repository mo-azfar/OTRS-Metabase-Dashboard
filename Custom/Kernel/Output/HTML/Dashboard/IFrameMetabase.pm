# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
#for metabase dashboard
#28112020 - add support for hiding multiple metabase filter
#06122020 - registered metabase jwt as system api and use it instead.

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
		
	#to support multiple parameter send to metabase. Separator ; 
	my @TotalParam;
	my @SplitParam = split /;/, $Self->{Config}->{'HideParam'};
	foreach my $NewParam ( @SplitParam )
	{
		my ($ParamKey, $ParamValue) = split /=/, $NewParam;
		$ParamValue = $Self->{$ParamValue};
		#$Self->{UserFullname}
		#$Self->{UserLogin}
		push @TotalParam, $ParamKey => $ParamValue; 
	}
	
	my $URL = $Metabase->GenerateTokenURL(
		MetabaseURL => $Self->{Config}->{'MetabaseURL'},
		SecretKey    => $Self->{Config}->{'SecretKey'},
		DashboardID  => int($Self->{Config}->{'DashboardID'}),
		MinutesExpired  => int($Self->{Config}->{'MinutesExpired'}),
		HideParam      => \@TotalParam,
	);
	
	$Self->{Config}->{'URL'} = $URL;

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
