TEXMFLOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
STRIPTARGET = gachimuchi.cls gachimuchimacro.sty gachimuchipatch.sty
DOCTARGET = gachimuchi gachimuchimacro gachimuchipatch
PDFTARGET = $(addsuffix .pdf,$(DOCTARGET))
DVITARGET = $(addsuffix .dvi,$(DOCTARGET))
LATEXENGINE := uplatex #lualatex
LOGSUFFIXES = .aux .log .toc .mx1 .mx2 .bcf .bbl .blg .idx .ind .ilg .out .run.xml .glo .gls

define move
	$(foreach tempsuffix,$(LOGSUFFIXES),$(call movebase,$1,$(tempsuffix)))
	
endef
define movebase
	if [ -e $(addsuffix $2,$1) ]; then mv $(addsuffix $2,$1) ./logs; fi
	
endef

all: $(STRIPTARGET) $(PDFTARGET)
strip: $(STRIPTARGET)
doc: $(PDFTARGET)

class: gachimuchi.cls gachimuchi.pdf
macro: gachimuchimacro.sty gachimuchimacro.pdf
patch: gachimuchipatch.sty gachimuchipatch.pdf
clsinstl: gachimuchi.cls gachimuchi.pdf
	make install STRIPTARGET=gachimuchi.cls PDFTARGET=gachimuchi.pdf
mcrinstl: gachimuchimacro.sty gachimuchimacro.pdf
	make install STRIPTARGET=gachimuchimacro.sty PDFTARGET=gachimuchimacro.pdf
ptcinstl: gachimuchipatch.sty gachimuchipatch.pdf
	make install STRIPTARGET=gachimuchipatch.sty PDFTARGET=gachimuchipatch.pdf
.PHONY: install clean cleanstrip cleanall cleandoc movelog


gachimuchi.cls: gachimuchi.dtx
	pdflatex gachimuchi.ins

gachimuchimacro.sty: gachimuchimacro.dtx
	pdflatex gachimuchimacro.ins

gachimuchipatch.sty: gachimuchipatch.dtx
	pdflatex gachimuchipatch.ins


.SUFFIXES: .dtx .dvi .pdf

ifeq ($(LATEXENGINE),lualatex)
.dtx.pdf:
	lualatex $<
	makeindex -s gind.ist $(basename $<)
	makeindex -s gglo.ist -o $(addsuffix .gls,$(basename $<)) $(addsuffix .glo,$(basename $<))
	lualatex -synctex=1 $<
	rm -f $(addsuffix .toc,$(basename $<)) \
	$(addsuffix .out,$(basename $<)) \
	$(addsuffix .aux,$(basename $<))
else
.dtx.dvi:
	uplatex $<
	if [ -e $(basename $<).idx ]; then makeindex -s gind.ist $(basename $<); fi
	if [ -e $(basename $<).glo ]; then makeindex -s gglo.ist -o $(addsuffix .gls,$(basename $<)) $(addsuffix .glo,$(basename $<)); fi
	uplatex -synctex=1 $<
	rm -f $(addsuffix .toc,$(basename $<)) \
	$(addsuffix .out,$(basename $<)) \
	$(addsuffix .aux,$(basename $<))
.dvi.pdf:
	dvipdfmx $<
endif

install: $(STRIPTARGET) $(PDFTARGET)
	mkdir -p $(TEXMFLOCAL)/tex/platex/bellMacros
	install $(STRIPTARGET) $(TEXMFLOCAL)/tex/platex/bellMacros
	mkdir -p $(TEXMFLOCAL)/doc/platex/bellMacros
	install $(PDFTARGET) $(TEXMFLOCAL)/doc/platex/bellMacros

movelog:
	mkdir -p ./logs
	$(foreach temp,$(DOCTARGET),$(call move,$(temp)))

clean:
	rm -f \
	$(addsuffix .idx,$(DOCTARGET)) \
	$(addsuffix .ind,$(DOCTARGET)) \
	$(addsuffix .ilg,$(DOCTARGET)) \
	$(addsuffix .glo,$(DOCTARGET)) \
	$(addsuffix .gls,$(DOCTARGET)) \
	$(addsuffix .aux,$(DOCTARGET)) \
	$(addsuffix .toc,$(DOCTARGET)) \
	$(addsuffix .mx1,$(DOCTARGET)) \
	$(addsuffix .log,$(DOCTARGET))

cleanall:
	rm -f $(PDFTARGET) \
	$(DVITARGET) \
	$(STRIPTARGET) \
	make clean

makelog:
	git log --oneline --decorate --graph --all 1> "log_all.txt"
	git log --oneline --decorate --graph 1> "log.txt"
