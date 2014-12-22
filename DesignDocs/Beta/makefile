CMD_SEP = "========================================"
CMD_DONE = "Done."
CLEAN_CMD = rm -f *.aux       ; \
            rm -f *.bbl       ; \
            rm -f *.blg       ; \
            rm -f *-blx.bib   ; \
            rm -f *.log       ; \
            rm -f *.out       ; \
            rm -f *.run.xml   ; \
            rm -f *.toc       ; \
            rm -f *.lof       ; \
            rm -f *.lot       ; \
            rm -f *.lol       ; \
            rm -f comment.cut ; \

all: full

quick:
	@echo "QUICK BUILD"
	@echo
	@echo $(CMD_SEP)
	@echo "Building bibliography..."
	bibtex frienso_beta
	@echo $(CMD_DONE)
	@echo $(CMD_SEP)
	@echo
	@echo $(CMD_SEP)
	@echo "Building frienso_beta..."
	pdflatex frienso_beta
	@echo $(CMD_DONE)
	@echo $(CMD_SEP)
	@echo

full:
	@echo "FULL BUILD"
	@echo
	@echo $(CMD_SEP)
	@echo "Building frienso_beta (1st time)..."
	pdflatex frienso_beta
	@echo $(CMD_DONE)
	@echo $(CMD_SEP)
	@echo
	@echo $(CMD_SEP)
	@echo "Building bibliography..."
	bibtex frienso_beta
	@echo $(CMD_DONE)
	@echo $(CMD_SEP)
	@echo
	@echo $(CMD_SEP)
	@echo "Rebuilding frienso_beta (2nd time)..."
	pdflatex frienso_beta
	@echo $(CMD_DONE)
	@echo $(CMD_SEP)
	@echo
	@echo $(CMD_SEP)
	@echo "Rebuilding frienso_beta (3rd time)..."
	pdflatex frienso_beta
	@echo $(CMD_DONE)
	@echo $(CMD_SEP)
	@echo
	@echo $(CMD_SEP)
	@echo "Rebuilding frienso_beta (4th time)..."
	pdflatex frienso_beta
	@echo $(CMD_DONE)
	@echo $(CMD_SEP)
	@echo
	@echo $(CMD_SEP)
	@echo "Rebuilding frienso_beta (last time)..."
	pdflatex frienso_beta
	@echo $(CMD_DONE)
	@echo $(CMD_SEP)
	@echo

clean:
	@echo $(CMD_SEP)
	@echo "Cleaning '.' folder..."
	@-$(CLEAN_CMD)
	@echo $(CMD_DONE)
	@echo $(CMD_SEP)

new: clean
	@echo "NEW BUILD"
	@echo
	@echo $(CMD_SEP)
	@echo "Building frienso_beta..."
	pdflatex frienso_beta
	@echo $(CMD_DONE)
	@echo $(CMD_SEP)
	@echo
