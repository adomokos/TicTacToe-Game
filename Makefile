REPORTER = dot

test: test-bdd

test-bdd:
	@./node_modules/mocha/bin/mocha \
		--reporter $(REPORTER) \
		--ui bdd \

test-doc:
	@./node_modules/mocha/bin/mocha \
		--reporter list \
		--ui bdd \

