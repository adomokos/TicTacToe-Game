REPORTER = dot

test: test-bdd

test-bdd:
	@./node_modules/mocha/bin/mocha \
		--require coffee-script \
		--reporter $(REPORTER) \
		--ui bdd \

test-doc:
	@./node_modules/mocha/bin/mocha \
		--require coffee-script \
		--reporter list \
		--ui bdd \

