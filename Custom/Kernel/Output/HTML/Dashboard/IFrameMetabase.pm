# --
# Copyright (C) 2023 mo-azfar, https://github.com/mo-azfar
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Output::HTML::Dashboard::IFrameMetabase;

use strict;
use warnings;

# prevent 'Used once' warning
use Kernel::System::ObjectManager;

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

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');
    my $CacheKey   = 'UserMetabase' . '-' . $Self->{UserLogin};
   
    my $Content = $CacheObject->Get(
        Type => 'UserMetabase',
        Key  => $CacheKey,
    ); 
    
    if (defined ($Content))
    {
        return $Content;
    }
	else
    {	
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
        
        my $Metabase = $Kernel::OM->Get('Kernel::System::Metabase');
        
        my $URL = $Metabase->GenerateTokenURL(
            MetabaseURL => $Self->{Config}->{'MetabaseURL'},
            SecretKey    => $Self->{Config}->{'SecretKey'},
            DashboardID  => int($Self->{Config}->{'DashboardID'}),
            MinutesExpired  => int($Self->{Config}->{'MinutesExpired'}),
            HideParam      => \@TotalParam,
        );
        
        $Self->{Config}->{'URL'} = $URL;

        $Content = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Output(
            TemplateFile => 'AgentDashboardIFrame',
            Data         => {
                %{ $Self->{Config} },
                Title => $Title,
            },
        );

        # cache dashboard as long the token key alive
        $CacheObject->Set(
            Type  => 'UserMetabase',
            Key   => $CacheKey,
            Value => $Content || '',
            TTL   => int($Self->{Config}->{'MinutesExpired'}) * 60,
        );

    }

    return $Content;
}

1;