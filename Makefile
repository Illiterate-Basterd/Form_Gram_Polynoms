CC = gcc

LEX = flex
LEXER = Polynom.l
BUILDDIR = build
BISON = bison
PARSER = Polynom.y
MAIN = Polynom.c
ANALYZER = PolyCalc


build: $(BUILDDIR)/$(ANALYZER)

$(BUILDDIR)/$(ANALYZER):
	mkdir -v $(BUILDDIR)
	cp src/Polynom* $(BUILDDIR)
	$(BISON) -yd -Wno-yacc $(BUILDDIR)/$(PARSER) -o $(BUILDDIR)/y.tab.c
	$(LEX) -o $(BUILDDIR)/lex.yy.c $(BUILDDIR)/$(LEXER)
	$(CC) $(BUILDDIR)/$(MAIN) $(BUILDDIR)/lex.yy.c $(BUILDDIR)/y.tab.c -o $(BUILDDIR)/$(ANALYZER)
	rm -f $(BUILDDIR)/Polynom*


clean:
	rm -rf $(BUILDDIR)


test:
	$(BUILDDIR)/$(ANALYZER) src/Test.plnm
