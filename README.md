Tool to prepare ICoFoI  transcripts for SayIt
=============

Ended up here:
http://icofoi2016.sayit.mysociety.org/

Actual process was:

* create SayIt instance
* create Akoma Ntoso XML versions of transcripts (this script)
* upload them using "Import Speeches"
* hand-edit the sections and speakers in SayIt (e.g., adding headshot URLs) 
 
---

SayIt: http://sayit.mysociety.org/

The Independent Commission on Freedom of Expression:
https://www.gov.uk/government/organisations/independent-commission-on-freedom-of-information


[Two transcripts are available](https://www.gov.uk/government/publications/independent-commission-on-freedom-of-information-oral-evidence-transcripts)
of the oral evidence sessions. Both are duplicated in the `sources` directory
of this repo (together with the output from running those through `pdftotext`
with `--enc 'UTF-8'`):

* [20 January 2016 transcript](https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/494574/icofoi_oral_evidence_transcript_20_Jan.pdf)
  PDF, 305KB, 94 pages

* [25 January 2016 uncorrected transcript](https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/494934/ICFOI-oral-evidence-transcript-25-January16.pdf)
  PDF, 492KB, 192 pages
 
This `parse.pl` was a hacky script for turning them into importable AN XML,
which SayIt happily consumes.
 