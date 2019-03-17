SHELL = /bin/bash
BUILD_DIR = build/
TEMPLATE_DIR = templates/
IMAGES_DIR = images/
CSS_FILE = style.css
VERSION = $(shell git describe --abbrev=0 --tags)
VERSION := $(if $(VERSION),$(VERSION),none)
OUTPUT_BASENAME = $(shell basename $(CURDIR))-$(VERSION)

# CHAPTERS = text/*.md
CHAPTERS = $(shell find text -type f -name '*.md' | sort )
SLIDES = $(shell find slides -type f -name '*.md' | sort )
METADATA = metadata.yml
LATEX_CLASS = book

EPUB_BUILDER_FLAGS = \
	--epub-cover-image=$(IMAGES_DIR)cover.png \
	--css=templates/$(CSS_FILE) \
	--template=templates/epub.html \
	--metadata-file=$(METADATA) \
	--metadata=version:$(VERSION) \
	--lua-filter templates/latex.lua \
	--toc --toc-depth=2 \
	--webtex

HTML_BUILDER_FLAGS = \
	--css=templates/$(CSS_FILE) \
	--standalone --to=html5 \
	--metadata-file=$(METADATA) \
	--lua-filter templates/latex.lua \
	--toc --toc-depth=2 \
	--self-contained \
	--webtex

BEAMER_BUILDER_FLAGS = \
	--pdf-engine=xelatex \
	-t beamer \
	--metadata=aspectratio:169 \
	--template=templates/beamer.tex \
	--slide-level 2

PDF_BUILDER_FLAGS = \
	-V documentclass=$(LATEX_CLASS) \
	--template=templates/pdf.tex \
	--metadata=version:$(VERSION) \
	--lua-filter templates/latex.lua \
	--pdf-engine=xelatex \
	--toc --toc-depth=2 \
	--webtex

WORD_BUILDER_FLAGS = \
	--reference-doc=templates/reference.docx \
	--metadata-file=$(METADATA) \
	--lua-filter templates/latex.lua

MOBI_BUILDER = kindlegen

.PHONY: show-args
show-args:
	@printf "Project Version: %s\n" $(VERSION)

all: pdf slides

# book: pdf html epub

clean:
	rm -r $(BUILD_DIR)*

docx:
	mkdir -p $(BUILD_DIR)
	pandoc $(WORD_BUILDER_FLAGS) -o $(BUILD_DIR)$(OUTPUT_BASENAME).docx $(CHAPTERS)

pdf:
	mkdir -p $(BUILD_DIR)
	pandoc $(PDF_BUILDER_FLAGS) -o $(BUILD_DIR)$(OUTPUT_BASENAME).pdf $(CHAPTERS)

html:
	mkdir -p $(BUILD_DIR)html
	cp -R $(IMAGES_DIR) $(BUILD_DIR)html/$(IMAGES_DIR)
	pandoc $(HTML_BUILDER_FLAGS) -o $(BUILD_DIR)html/$(OUTPUT_BASENAME).html $(CHAPTERS)

slide:
	pandoc $(BEAMER_BUILDER_FLAGS) -o $(BUILD_DIR)$(OUTPUT_BASENAME).slides.pdf $(SLIDES)

handout:
	pandoc $(BEAMER_BUILDER_FLAGS) -V handout -o $(BUILD_DIR)$(OUTPUT_BASENAME).handout.pdf $(SLIDES)
	pdfnup $(BUILD_DIR)$(OUTPUT_BASENAME).handout.pdf --nup 1x3 --no-landscape --keepinfo \
			--paper letterpaper --frame true --scale 0.9 \
			--suffix "nup"


$(BUILD_DIR)$(OUTPUT_BASENAME).epub:
	mkdir -p $(BUILD_DIR)
	pandoc $(EPUB_BUILDER_FLAGS) -o $(BUILD_DIR)$(OUTPUT_BASENAME).epub $(CHAPTERS)


epub: $(BUILD_DIR)$(OUTPUT_BASENAME).epub



# %.md.handout.pdf : %.md
# 	pandoc $^ -t beamer --slide-level 2 -V handout -o $@
# 	pdfnup $@ --nup 1x2 --no-landscape --keepinfo \
# 		--paper letterpaper --frame true --scale 0.9 \
# 		--suffix "nup"
# 	mv $*.md.handout-nup.pdf $@
