require! {
	should
	\../get-val.js : GetVal
}

<-! describe \GetVal

exceptions = GetVal.exceptions

specify 'Incorrect argument throws exception', !->
	try
		new GetVal 1
	catch
		void
	e.should.instance-of exceptions.IncorrectArgument

	try
		new GetVal {}
	catch
		void
	e.should.instance-of exceptions.RequiredArgumentKey

	try
		new GetVal values: {}
	catch
		void
	e.should.instance-of exceptions.RequiredArgumentKey

	new GetVal values: {}, required: []

	try
		new GetVal values: {}, required: {}
	catch
		void
	e.should.instance-of exceptions.RequiredArgumentKey

	try
		new GetVal values: [], required: []
	catch
		void
	e.should.instance-of exceptions.RequiredArgumentKey

	try
		new GetVal {values: {}, required: []}, 1
	catch
		void
	e.should.instance-of exceptions.IncorrectArgument

	new GetVal values: {}, required: [false]

specify 'Create example and get value', !->
	get-val = new GetVal values: {foo: 1, bar: 2}, required: []
	a = get-val \foo
	b = get-val \bar
	a.should.eql 1
	b.should.eql 2

specify 'Key is not exists throws exception', !->
	get-val = new GetVal values: {foo: 1, bar: 2}, required: []
	try
		get-val \check
	catch
		void
	e.should.instance-of exceptions.KeyIsNotExists

specify '
Attempt to get value before all required values is setted
\ throws exception', !->
	get-val = new GetVal values: {foo: 1, bar: 2}, required: <[check]>
	try
		get-val \foo
	catch
		void
	e.should.instance-of exceptions.RequiredIsNotSet

	# also for required sets at instance creating
	values =
		values:
			foo: 1
			bar: 2
		required:
			\a
			\b
			\c
	required-set =
		a: 1
		b: 2
	get-val2 = new GetVal values, required-set
	try
		get-val2 \foo
	catch
		void
	e.should.instance-of exceptions.RequiredIsNotSet

specify '
Get value before all required values is setted
\ using special flag', !->
	get-val = new GetVal values: {foo: 1, bar: 2}, required: <[check]>
	get-val \foo , true .should.eql 1

specify 'Set required values', !->
	get-val = new GetVal values: {foo: 1, bar: 2}, required: <[a b]>
	get-val.super.set \a, 1
	get-val.super.set \b, 2

specify 'Get required values', !->
	get-val = new GetVal values: {foo: 1, bar: 2}, required: <[a b]>
	get-val.super.set \a, 1
	get-val.super.set \b, 2
	a = get-val \a
	b = get-val \b
	a.should.eql 1
	b.should.eql 2
	# also check get non-required values
	foo = get-val \foo
	bar = get-val \bar
	foo.should.eql 1
	bar.should.eql 2

specify '
Attempt to set required value
\ that not in required list throw exception', !->
	get-val = new GetVal values: {foo: 1, bar: 2}, required: <[a b]>
	try
		get-val.super.set \check, 1
	catch
		void
	e.should.instance-of exceptions.NoKeyInRequiredList

specify '
Set required values at instance creating (as second argument)', !->
	values =
		values:
			foo: 1
			bar: 2
		required:
			\a
			\b
	required-set =
		a: 1
		b: 2
	get-val = new GetVal values, required-set
	get-val \foo .should.eql 1
	get-val \bar .should.eql 2
	get-val \a .should.eql 1
	get-val \b .should.eql 2

specify 'Required list is optional for create instance', !->
	get-val = new GetVal values: {foo: 1, bar: 2}
	get-val \foo
	get-val \bar

specify '
"get" method wrapper has "set" method wrapper', !->
	values =
		values: {a: 1, b: 2}
		required: <[c]>
	get-val = new GetVal values
	try
		get-val \a
	catch
		void
	e.should.instance-of exceptions.RequiredIsNotSet

	get-val.set.should.instance-of Function
	get-val.set \c 3
	get-val \c .should.eql 3

# exceptions

specify 'Exceptions is instance of Error', !->
	for key, exception of exceptions
		err = new exception
		err.should.instance-of Error

specify 'Exceptions is instance of itself', !->
	for key, exception of exceptions
		err = new exception
		err.should.instance-of exception

specify 'Exceptions is not instance of each other', !->
	i = 0
	for key, exception of exceptions
		if i is 0 then a = exception
		else if i is 1 then b = exception
		else break
		i++
	err-a = new a
	err-b = new b
	err-a.should.not.instance-of b
	err-b.should.not.instance-of a

specify 'Exceptions own names', !->
	for name, exception of exceptions
		err = new exception
		real-name = err.toString!.replace /:.*$/, ''
		if real-name is not name
			throw new Error "Names doesn't match
				\ (real name is: \"#{real-name}\"
				, but must be \"#{name}\")."
