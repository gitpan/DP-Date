#------------------------------------------------------
#
#	Date
#
#------------------------------------------------------
# 2002/06/04 - $Date: 2003/12/12 11:00:15 $
# (C) Daniel Peder & Infoset s.r.o., all rights reserved
# http://www.infoset.com, Daniel.Peder@infoset.com
#------------------------------------------------------
# $Revision: 1.6 $
# $Date: 2003/12/12 11:00:15 $
# $Id: Date.pm_rev 1.6 2003/12/12 11:00:15 root Exp root $


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

	package DP::Date;

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

	use vars qw( $VERSION );
	
	$VERSION = '0.101';

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

	require 5.005_62;

	use strict;
	use warnings;


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 
#
#	POD SECTION
#
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

=head1 NAME

DP::Date - Date manipulation support

=head1 SYNOPSIS

  use DP::Date;
  
  ...
  ...
  

=head1 DESCRIPTION

=head2 METHODS

=over 4

=cut


# some helpers and constants
my $TimeSec = time();
my @TimeParts = gmtime( $TimeSec ); $TimeParts[4]++; $TimeParts[5]+=1900;
my $TimeString = sprintf '%04d%02d%02d000000', @TimeParts[5,4,3];
my $YearMonthTimeTable = {};
sub MonthNames {'jan feb mar apr may jun jul aug sep oct nov dec '}












=item new

 $DateObject = DP::Date->new( [ $Date_asString ] )

 index of $DateObject [ blessed array ]
 0 - date as string
 1 - date as time() - secs since epoch
 2 - weekday from local time
 3 - yearday from local time

=cut

sub new
{
	my $ref = shift();
	my $val = shift();
	my $self = [];
	bless $self, __PACKAGE__;
	if( defined( $val ))
	{
		$self->asString( $val );
	}
	else
	{
		$self->asTime( time );
	}
	$self
}

#
# $self fields
# 0 - date as string
# 1 - date as time() - secs since epoch
# 2 - weekday from local time
# 3 - yearday from local time
#









=item asString

 $Date_asString = $DateObject->asString( [ $SetDate_asString ] )
 
Get/Set string-of-numbers formatted value date-time value of B<$DateObject> to $SetDate_asString.
 
B< $Date_asString > is string of date numbers without any punctuation,
thus having the date-time '2003-12-24 20:00:00' produces 
date asString '20031224200000'

=cut

sub asString
{
	my $self = shift();
	my( $val ) = @_;
	if( defined $val )
	{
		$$self[0] = $val.(($_=length($val)-14)>0 ?substr($TimeString,$_):'');
		$$self[1] = $self->str2time( $$self[0] );
	}
	$$self[0]
}










=item asTime

 $Date_asTime = $DateObject->asTime( [ $setDate_asTime | time ] )
 
Get/Set date-time value of B<$DateObject> to $setDate_asTime.
 
B< $Date_asTime > is compatible with perl's time(), ( eg. seconds elapsed since 1.1.1970? )

=cut

sub asTime
{
	my $self = shift();
	my( $val ) = @_;
	if( defined $val )
	{
		#$_ = [gmtime( $val )]; $$_[4]++; $$_[5]+=1900;
		$_ = [localtime( $val )]; $$_[4]++; $$_[5]+=1900;
		$$self[0] = sprintf '%04d%02d%02d%02d%02d%02d', @$_[5,4,3,2,1,0];
		@$self[2,3] = @$_[6,7];
		$$self[1] = $val;
	}
	$$self[1]
}












=item asISO

 $Date_asISO = $DateObject->asISO( [ $setDate_asISO ] )
 
Get/Set ISO formatted date-time value of B<$DateObject> to $setDate_asTime.
 
B< $Date_asISO > example: B<2003-12-24 20:00:00>  ( no timezone, no 'T' letter as sometimes used 2003-12-24T20:00:00 )

 # MUST be EXACTLY this format: 2002-12-24 12:34:56 (YYYY-MM-DD hh:mm:ss)
 # no checking, 2b faster
 
=cut

sub asISO
{
	my $self = shift();
	my( $val ) = @_;
	if( defined $val )
	{
		# MUST be EXACTLY this format: 2002-12-24 12:34:56 (YYYY-MM-DD hh:mm:ss)
		# no checking, 2b faster
		$self->asString( join('',unpack( 'A4xA2xA2xA2xA2xA2', $val )));
	}
	sprintf '%04d-%02d-%02d %02d:%02d:%02d', unpack( 'A4A2A2A2A2A2', $$self[0] );
}








=item GetAsISO

 $Date_asISO = $DateObject->GetAsISO()
 
Get ISO formatted value of B<$DateObject> to $setDate_asTime.
See also B<asISO()> method.
 
=cut

sub GetAsISO
{
	my $self = shift();
	sprintf '%04d-%02d-%02d %02d:%02d:%02d', unpack( 'A4A2A2A2A2A2', $$self[0] );
}










=item GetAsArray

 @Date_array = $DateObject->GetAsISO()
 
Get array of values of B<$DateObject> to $setDate_asTime,
where @Date_array = ( $YYYY, $MM, $DD, $hh, $mm, $ss )
See also B<asISO()> method.
 
=cut

sub GetAsArray
{
	my $self = shift();
	unpack( 'A4A2A2A2A2A2', $$self[0] );
}











=item SetStringAtOffset

 $Date_asString = $DateObject->SetStringAtOffset( $offset, $newStringValue )
 
Example: want to change hour value of $DateObject

 my $DateObject = DP::Date->new();
 $DateObject->SetStringAtOffset( 8, '20' );   # initial date: 2003-12-24 12:34:56
 $Date_asISO = $DateObject->GetAsISO();       # changed hour: 2003-12-24 20:34:56
 
Offsets:
 year......  0 +4 
 month.....  4 +2
 day.......  6 +2
 hour......  8 +2
 min....... 10 +2
 sec....... 12 +2

=cut

sub SetStringAtOffset
{
	my $self = shift();
	my( $offset, $val ) = @_;
	substr( $$self[0], $offset, length($val) ) = $val;
	$self->asString( $$self[0] );
}



=item Year

Get/Set

 $DateObject->Year( [ $YYYY ] )

=cut

sub Year
{
	my $self = shift();
	my( $val ) = @_;
	my( $offset );
	$offset = 0;
	if( $val )
	{
		$self->SetStringAtOffset( $offset, sprintf( '%04d', $self->yy2yyyy( $val ) ));
	}
	substr( $$self[0], $offset, 4 );
}
sub yy2yyyy{ my $y = $_[1]; $y += $y < 90 ? 2000 : $y < 100 ? 1900 : 0; $y }
sub mmm2mm
{
	my $m = $_[1];
	return undef if( 4 > ( $_ = index( MonthNames, lc(substr($_[1],0,3)))+4 ));
	$_ / 4
}











=item Month

Get/Set

 $MonthNr = $DateObject->Month( [ $Month_name_as_english_3letters_abbr ] )

=cut

sub Month
{
	my $self = shift();
	my( $val ) = @_;
	my( $month );
	unless( $month = $self->mmm2mm( $val ))
	{
		return undef;
	}
	elsif( $val=~/^\d+$/o )
	{
		$month = $val;
	}
	$self->MonthNr( $month )
}












=item MonthNr

Get/Set

 $MonthNr = $DateObject->MonthNr( [ $Month_as_two_digits_based_JAN_eq_01 ] )

=cut

sub MonthNr
{
	my $self = shift();
	my( $val ) = @_;
	my( $offset );
	$offset = 4;
	if( $val )
	{
		$self->SetStringAtOffset( $offset, sprintf( '%02d', $val % 100 ));
	}
	substr( $$self[0], $offset, 2 );
}












=item Day

Get/Set

 $Day = $DateObject->Day( [ $Day_of_month_as_two_digits ] )

=cut

sub Day
{
	my $self = shift();
	my( $val ) = @_;
	my( $offset );
	$offset = 6;
	if( $val )
	{
		$self->SetStringAtOffset( $offset, sprintf( '%02d', $val % 100 ));
	}
	substr( $$self[0], $offset, 2 );
}














=item Hour

Get/Set

 $Hour = $DateObject->Hour( [ $Hour_as_two_digits ] )

=cut

sub Hour
{
	my $self = shift();
	my( $val ) = @_;
	my( $offset );
	$offset = 8;
	if( $val )
	{
		$self->SetStringAtOffset( $offset, sprintf( '%02d', $val % 100 ));
	}
	substr( $$self[0], $offset, 2 );
}













=item Minute

Get/Set

 $Minute = $DateObject->Minute( [ $Minute_as_two_digits ] )

=cut

sub Minute
{
	my $self = shift();
	my( $val ) = @_;
	my( $offset );
	$offset = 10;
	if( $val )
	{
		$self->SetStringAtOffset( $offset, sprintf( '%02d', $val % 100 ));
	}
	substr( $$self[0], $offset, 2 );
}

















=item Second

Get/Set

 $Second = $DateObject->Second( [ $Second_as_two_digits ] )

=cut

sub Second
{
	my $self = shift();
	my( $val ) = @_;
	my( $offset );
	$offset = 12;
	if( $val )
	{
		$self->SetStringAtOffset( $offset, sprintf( '%02d', $val % 100 ));
	}
	substr( $$self[0], $offset, 2 );
}








=item GetWeekDay

Get

 $GetWeekDay = $DateObject->GetWeekDay

=cut

sub GetWeekDay
{
	my $self = shift();
	if( !defined( $$self[2] ))
	{
		$self->asTime( $$self[1] ); # reparse to get [WY]day components
	}
	$$self[2]
}














=item GetYearDay

Get

 $GetYearDay = $DateObject->GetYearDay

=cut

sub GetYearDay
{
	my $self = shift();
	if( !defined( $$self[3] ))
	{
		$self->asTime( $$self[1] ); # reparse to get [WY]day components
	}
	$$self[3]
}







=item str2time

see source code, sorry

=cut

sub str2time
{
	my $self = shift();
	my( $str ) = @_;
	my( @time, $secs, $wday, $yday );
	@time = unpack( 'A4A2A2A2A2A2', $str ); # $str must be in format YYYYMMDDhhmmss right zero '0' padded to 14chars length
	$secs = $self->GetYearMonthBeginTime( @time[0,1] );
	$secs += ((($time[2]-1)*24 +$time[3])*60 +$time[4])*60 +$time[5];
	$secs
}

=item cmpString

see source code, sorry

=cut

sub cmpString
{
	my $self = shift();
	my( $cmpSize ) = @_;
	substr( $$self[0], 0, ($cmpSize||8));
}











=item isSameDateAs

Compare $DateObject with $anotherDateObject

 $bool = $DateObject->isSameDateAs( $anotherDateObject [, $comparingSize ] )
 
B< $comparingSize > is length of compared date-string .

see also B< asString > and B< cmpString > methods.

=cut

sub isSameDateAs
{
	my $self = shift();
	my( $cmpDate, $cmpSize ) = @_;
	$cmpSize ||= 8;
	return $self->cmpString( $cmpSize ) eq $cmpDate->cmpString( $cmpSize ) ? 1 : 0;
}












=item GetYearMonthBeginTime

Get the time-value at which the specified month of the year begins. Very usefull!
Values are cached as speed improvement.

 $time_value = $DateObject->GetYearMonthBeginTime( $YYYY_or_YY_string, $MM_string )
 
see also B< asTime > method.

=cut

sub GetYearMonthBeginTime
{
	my $self = shift();
	my $y = $self->yy2yyyy( 0+shift() );
	my $m = 0+shift();
	return $_ if $_ = $$YearMonthTimeTable{$y}{$m};
	my $diff = ($TimeParts[5]+($TimeParts[4]/12)-1) - ($y+($m/12)-1);
	my $secs = $TimeSec - ((( int( $diff * 365 ) + int( $diff / 4 ) + $TimeParts[3] - 5 )*24 +$TimeParts[2])*60 +$TimeParts[1])*60 +$TimeParts[0];
	#$days = ( int( $diff * 365 ) + int( $diff / 4 ) + $TimeParts[3] - 5 );  
	$_ = [gmtime($secs)]; $$_[4]++; $$_[5]+=1900;
	$secs -= (($$_[3]-1)*24*60*60) + $$_[1]*60 + $$_[0];
	$$YearMonthTimeTable{$y}{$m} = $secs;
}

1;

__END__

=head1 EXPORT

nothing

=head1 FILES

none

=head1 REVISION

project started: 2002/06/04

$Id: Date.pm_rev 1.6 2003/12/12 11:00:15 root Exp root $


=head1 AUTHOR

 Daniel Peder
 <Daniel.Peder@InfoSet.COM>
 http://www.infoset.com
 Czech Republic national-flag: 
 LeftSideBlueTriangleRightSideHorizontalSplitTopWhiteBottomRed

=head1 SEE ALSO

other date time modules at CPAN, http://www.CPAN.org

=cut

# $Log: Date.pm_rev $
# Revision 1.6  2003/12/12 11:00:15  root
# pod documentation - detailed method descriptions added
#
# Revision 1.5  2003/12/12 09:44:37  root
# *** empty log message ***
#
# Revision 1.4  2003/12/12 09:43:47  root
# dsitro changes
#
# Revision 1.3  2003/07/04 14:17:41  root
# localtime version
#
# Revision 1.2  2003/07/03 00:17:08  root
# *** empty log message ***
#
# Revision 1.1  2003/07/02 23:53:47  root
# Initial revision
#
# Revision 1.7  2002/06/12 20:13:35  root
# test input argument of new method to be defined
# instead of simpliest true test to enable the new('0000') construct
#
# Revision 1.6  2002/06/07 20:00:50  root
# removed VERSION::RCS module use
#
# Revision 1.5  2002/06/07 10:19:24  root
# fixed bug in asString - setting value fo date string length 14
#
# Revision 1.4  2002/06/06 15:33:01  root
# untested GetWeekDay and GetYearDay
#
# Revision 1.3  2002/06/04 20:05:58  root
# *** empty log message ***
#
# Revision 1.2  2002/06/04 16:52:16  root
# stable date init and compare
#
# Revision 1.1  2002/06/04 15:50:20  root
# Initial revision
#
# $LogEnd$

