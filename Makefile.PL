use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'DP::Date',
    'VERSION_FROM'	=> 'Date.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ? (
      # ABSTRACT_FROM => 'Date.pm', 
      AUTHOR     => 'Daniel Peder <Daniel.Peder@infoset.com>',
    ) : ()),
);
sub MY::postamble { q{

docs : README

README: Date.pm
	pod2text --loose Date.pm > README

xdist:
	[ -f MANIFEST ] && rm -f MANIFEST ; make realclean docs manifest tardist; perl Makefile.PL

}; }
