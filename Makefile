P=what-is-iot
# Madrid Pittsburgh boxes
SLIDE_THEME=boxes
PDFS=$(P)-text.pdf $(P)-slides.pdf
HTMLS=$(P)-reveal.html

ifeq (1,$(QUICK))
PP_DEFS+=QUICK
PDF_ENGINE   = pdflatex
PANDOC_ARGS += --no-highlight
else
PDF_ENGINE   = xelatex
PANDOC_ARGS += --highlight-style=pygments
endif

RUN_PP_BEAMER=pp -DBEAMER $(patsubst %,-D%,$(PP_DEFS))
RUN_PP_REVEALJS=pp -DREVEALJS $(patsubst %,-D%,$(PP_DEFS))
RUN_PANDOC_BEAMER=pandoc -f markdown -t beamer $(PANDOC_ARGS) -V theme:$(SLIDE_THEME) \
				  --pdf-engine=$(PDF_ENGINE)
RUN_PANDOC_REVEALJS=pandoc -f markdown -t revealjs -s -V revealjs-url=./bower_components/reveal.js
RUN_PANDOC_TEXT=pandoc -f markdown --pdf-engine=$(PDF_ENGINE)

all: toc.md $(PDFS) $(HTMLS)

slides: $(P)-slides.tex $(P)-slides.pdf
html: $(P)-reveal.html
.PHONY: html slides

clean:
	rm -f $(PDFS) $(HTMLS)

toc.md: $(P).md
	grep '^#' $< | sed -e 's,^# ,* ,' -e 's,^## ,    * ,' > $@

spell: .$(P).md.spell

.$(P).md.spell: $(P).md

.%.spell: %
	aspell --home-dir=. --personal=dictionary.txt --lang=en_US check $<
	touch $@

$(P).md: Makefile
	@touch $@

%.beamer.md: %.md
	$(RUN_PP_BEAMER) < $< > $@

%-text.pdf: %.beamer.md
	$(RUN_PANDOC_TEXT) -o $@ $<

%-slides.pdf: %.beamer.md
	$(RUN_PANDOC_BEAMER) -o $@ $<

%-slides.tex: %.beamer.md
	$(RUN_PANDOC_BEAMER) -o $@ $<

%.revealjs.md: %.md
	$(RUN_PP_REVEALJS) < $< > $@

%-reveal.html: %.revealjs.md
	$(RUN_PANDOC_REVEALJS) -o $@ $<

images/%.pdf: images/%.tex | images/pp-template Makefile
	images/pp-template < $< > $(patsubst %.tex,%-full.tex,$<)
	xelatex -output-directory=images $(patsubst %.tex,%-full.tex,$<)
	mv $(patsubst %.pdf,%-full.pdf,$@) $@

# Dependencies
$(P).md: images/IP-Header_eng.tex
$(P).md: images/ip-header.pdf
$(P).md: images/ip-header.svg
