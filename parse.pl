#!/usr/bin/perl

use strict;

make_akomantoso_for_sayit(
    filename  => 'icofoi-20-jan-16.txt',
    preface_end_string => 'Christopher Graham \(1.00 pm\)',
    doc_title => "Independent Commission on Freedom of Information: oral evidence, 20 Jan 2016",
    title =>  "Independent Commission on Freedom of Information: oral evidence, 20 Jan 2016"
);

make_akomantoso_for_sayit(
    filename  => 'icofoi-25-jan-16.txt',
    preface_end_string => 'Monday, 25 January 2016',
    doc_title => "Independent Commission on Freedom of Information: oral evidence, 25 Jan 2016",
    title =>  "Independent Commission on Freedom of Information: oral evidence, 25 Jan 2016"
);


sub make_akomantoso_for_sayit {
    my %data = @_;
    my $filename = $data{'filename'};
    my $text;
    binmode STDOUT, ":utf8";
    open INFILE, '<:encoding(utf8)', $filename
        or die("failed to open $filename to read: $!\n");
    while (<INFILE>) {
        $text .= $_;
    }
    close INFILE;
    print "\n[i] read " . length($text) . " chars from $filename\n";

    $text =~ s/.*?$data{'preface_end_string'}\s*//sm
      if defined $data{'preface_end_string'};

    my %speakers;
    my @speeches;
    
    my @chunks = split /((?:(?:[A-Z]+\s)+[A-Zc]+):)/, $text;
    my $current_speaker_id;
    foreach my $chunk (@chunks) {
        if ($chunk =~ /((?:[A-Z]+\s)+[A-Zc]+):/) {
            # it's a speaker
            my $this_speaker = $1;
            # note: MR SATCHWELL is a special case: see line 247 of icofoi-25
            if ($this_speaker =~ s/(.*[A-Z]+)\s+(THE CHAIRMAN|MR SATCHWELL)\s*$/$2/) {
                push @speeches, {
                    'narrative' => 1,
                    'paragraph' => "Introducing $1",
                };
            } elsif ($this_speaker =~ /\sAND\s/i) {
                print "[!] simultaneous speaker? $this_speaker\n";
                $this_speaker =~ s/\sAND\s.*//i;
            } 
            $current_speaker_id = slugify($this_speaker);
            my $cn = capitalised_name($this_speaker);
            # prefer the longest name in case it's found the middle name
            $speakers{$current_speaker_id} = $cn
                if length $cn > length $speakers{$current_speaker_id};
        } elsif ($current_speaker_id) {
            push @speeches, {
                'speaker-id' => $current_speaker_id,
                'paragraph' => enrich_punctuation($chunk),
            };
        } else {
            # nop: text here for which we have no speaker
            print "[?] $chunk\n" if $chunk=~/\S/;
        }
    }
    print "[i] number of speeches: " . scalar(@speeches) . "\n";
    print "[i] number of speakers: " . scalar(keys %speakers) . "\n";

    my $speaker_references_xml;
    for my $speaker_id (sort keys %speakers) {
        $speaker_references_xml .= 
          qq!        <TLCPerson id="$speaker_id" href="/ontology/person/icofoi.$speaker_id" showAs="!
          . $speakers{$speaker_id}
          . qq!"/>\n!;
    }

    my $slug_title = slugify($data{doc_title});
    
    my $akomantoso_xml = <<XML;
<akomaNtoso>
  <debate name="ICoFoI">
    <meta>
      <references source="#">
$speaker_references_xml
      </references>
    </meta>
    <preface>
      <docTitle>$data{doc_title}</docTitle>
    </preface>
    <debateBody>
      <debateSection name="$slug_title" id="$slug_title">
        <heading id="title">$data{title}</heading>
        <!-- SPEECHES -->
      </debateSection>
    </debateBody>
  </debate>
</akomaNtoso>
XML

    my $speeches_xml;
    foreach my $href (@speeches) {
        my %speech = %$href;
        my $p = minimal_xml_cleanup($speech{'paragraph'});
        my $xml;
        if ($speech{'narrative'}) {
            $xml = <<XML
        <narrative>
            $p
        </narrative>
XML
        } else {
            $xml = <<XML;
        <speech by="#$speech{'speaker-id'}">
          <p>
              $p
          </p>
        </speech>
XML
        }
        $speeches_xml .= $xml
    }

    $akomantoso_xml=~s/<!-- SPEECHES -->/$speeches_xml/;
    
    my $xmlfilename = $filename;
    if ($xmlfilename =~ s/.txt$/.xml/) {
        open OUTFILE, ">$xmlfilename" or die("failed to open $xmlfilename for write: $!");
        print OUTFILE $akomantoso_xml;
        close OUTFILE;
        print "[ ] wrote " . length($akomantoso_xml) . " characters to $xmlfilename\n";
    }
}

sub enrich_punctuation {
    my $s = shift;
    for ($s) {
        s/(?<!-)--(?!-)/—/g;
        s/(?<=\w)'/’/g;
        s/(?<!\w)'/‘/g;
        s/(?<=\w)"/”/g;
        s/(?<!\w)"/“/g;
        s/\s+-\s+/ — /g; # nitpick hyphens into emdashes
    }
    return $s;
}

sub capitalised_name {
    my $n = shift;
    $n =~ s/\b(\w)(\w+)/\U$1\L$2/g;
    return $n;
}

sub slugify {
    my $s = lc shift;
    # take out the middle name of mr-xxx-yyy (also dame, prof, ms, etc)
    # to normalise because sometimes both sneak through
    for ($s) {
        s/Independent Commission on Freedom of Information/icofoi/gi;
        s/\s+/ /g;
        s/_/-/g;
        s/--+/-/g;
        s/[^ A-Za-z-]//g; # letters spaces and hyphen only
        s/^(prof\w*|dame|mr|miss|mrs|ms|prof|rt-hon) \w+( \w.*)/$1$2/;
        s/\s+/-/g;
        s/[^a-z-]//g;
    }
    return $s;
}

sub minimal_xml_cleanup {
    my $s = shift;
    for ($s) {
        s/&/&amp;/g;
        s/</&lt;/g;
        s/>/&gt;/g;
    }
    return $s
}

