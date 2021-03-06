require 5.003000;

use strict;
use ExtUtils::MakeMaker;
use Getopt::Std;
use Config qw(%Config);

my $PM = 'lib/Digest/SHA.pm';

my %opts;
getopts('tx', \%opts);

my @defines;
push(@defines, '-DSHA_PERL_MODULE') if $] >= 5.004;
push(@defines, '-DSHA_THREAD_SAFE') if $opts{'t'};
push(@defines, '-DNO_SHA_384_512')  if $opts{'x'};

	# Configure SHA source to use static arrays for
	# message schedules if compiling on Intel platforms.
	# This seems to speed things up a bit.  However,
	# DON'T do this if thread-safe option is in force.
	
if ($Config{archname} =~ /^i[3456]86/) {
	push(@defines, '-DSHA_STO_CLASS=static') unless $opts{'t'};
}
my $define = join(' ', @defines);

	# Workaround for DEC compiler bug, adapted from Digest::MD5

my @extra = ();
if ($^O eq 'VMS') {
	if (defined($Config{ccname})) {
		if (grep(/VMS_VAX/, @INC) && ($Config{ccname} eq 'DEC')) {
			# VAX compiler optimizer even up to v6.4 gets stuck
			push(@extra, OPTIMIZE => "/Optimize=(NODISJOINT)");
		}
	}
}

my %att = (
	'NAME'		=> 'Digest::SHA',
	'VERSION_FROM'	=> $PM,
	'LIBS'		=> [''],
	'DEFINE'	=> $define,
	'INC'		=> '-I.',
	'EXE_FILES'	=> [ 'shasum' ],
	'INSTALLDIRS'	=> ($] >= 5.010 and $] < 5.011) ? 'perl' : 'site',
	@extra,
);

my $MMversion = $ExtUtils::MakeMaker::VERSION || 0;
$att{NO_META} = 1 unless $MMversion < 6.10_03;

WriteMakefile(%att);
