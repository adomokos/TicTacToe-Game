REPORTER = dot

test: test-bdd

test-bdd:
	@./node_modules/mocha/bin/mocha \
		spec/*.coffee \
		--require coffee-script \
		--reporter $(REPORTER) \
		--ui bdd \

test-doc:
	@./node_modules/mocha/bin/mocha \
		spec/*.coffee \
		--require coffee-script \
		--reporter list \
		--ui bdd \

package:
	@./node_modules/browserify/bin/cmd.js \
			public/js/ai_move.js \
			public/js/score_board.js \
			public/js/tic_tac_toe.js \
			-o public/js/application.js
