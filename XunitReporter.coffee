{MochaRunner, BaseReporter} = require("meteor/practicalmeteor:mocha")

class XUnitReporter extends BaseReporter

  xUnitPrefix: "##_meteor_magic##xunit: "

  constructor:(@clientRunner, @serverRunner, @options)->
    super(@clientRunner, @options)

    @clientStats = @stats
    @clientTests = []
    @serverTests = []

    @_addEventsToRunner('client')
    @_addEventsToRunner('server')


  _addEventsToRunner:(where)->

    @[where + "Runner"].on 'pending', (test) =>
      @[where+"Tests"].push test

    @[where + "Runner"].on 'pass', (test) =>
      @[where+"Tests"].push test

    @[where + "Runner"].on 'fail', (test) =>
      @[where+"Tests"].push test

    @[where + "Runner"].on 'end', (stats)=>

      if where is "client"
        @clientTestsEnded = true
      else
        @serverTestsEnded = true
        @serverStats = stats

      # Only when both runner has ended running print test suite
      # i.e @serverTestsEnded
      if @clientTestsEnded and @serverTestsEnded
        @printTestSuite()

  printTestSuite: ->

    testSuite = {
      name: 'Mocha Tests'
      tests: @clientStats.tests + @serverStats.tests
      failures: @clientStats.failures + @serverStats.failures
      errors: @clientStats.failures + @serverStats.failures
      timestamp: (new Date).toUTCString()
      time: (@clientStats.duration + @serverStats.duration) / 1000 or 0
    }
    testSuite.skipped =  testSuite.tests - (testSuite.failures) - (@clientStats.passes + @serverRunner.passes)

    @write @createTag('testsuite', testSuite, false)

    @clientTests.forEach (test) =>
      @printTestCase test, "Client"

    @serverTests.forEach (test) =>
      @printTestCase test, "Server"

    @write '</testsuite>'

    window.TEST_STATUS = {FAILURES: testSuite.failures, DONE: true}
    window.DONE = true
    window.FAILURES = testSuite.failures


  ###*
  # HTML tag helper.
  #
  # @param name
  # @param attrs
  # @param close
  # @param content
  # @return {string}
  ###
  createTag: (name, attrs, close, content) ->
    end = if close then '/>' else '>'
    pairs = []
    tag = undefined

    for key of attrs
      if Object.prototype.hasOwnProperty.call(attrs, key)
        pairs.push key + '="' + @escape(attrs[key]) + '"'

    tag = '<' + name + (if pairs.length then ' ' + pairs.join(' ') else '') + end

    if content
      tag += content + '</' + name + end

    return tag

  ###*
  # Return cdata escaped CDATA `str`.
  ###

  cdata: (str) ->
    '<![CDATA[' + @escape(str) + ']]>'

  ###*
  # Override done to close the stream (if it's a file).
  #
  # @param failures
  # @param {Function} fn
  ###

  done:(failures, fn) ->
      fn failures

  ###*
  # Write out the given line.
  #
  # @param {string} line
  ###

  write:(line) ->
    console.log @xUnitPrefix + line

  ###*
  # Output tag for the given `test.`
  #
  # @param {Test} test
  ###

  printTestCase:(test, where) ->
    attrs =
      classname: "#{where} #{test.parent.fullTitle()}"
      name: test.title
      time: test.duration / 1000 or 0

    if test.state == 'failed'
      err = test.err
      stack = @escapeStack(err.stack)
      @write @createTag('testcase', attrs, false, @createTag('failure', {}, false, @cdata(@escape(err.message) + '\n' + stack)))
    else if test.pending
      @write @createTag('testcase', attrs, false, @createTag('skipped', {}, true))
    else
      @write @createTag('testcase', attrs, true)
    return


  ###*
  # Escape special characters in the given string of html.
  #
  # @api private
  # @param  {string} html
  # @return {string}
  ###

  escape: (html) ->
    String(html)
      .replace(/&/g, '&amp;')
      .replace(/"/g, '&quot;')
      .replace(/</g, '&lt;')
      .replace />/g, '&gt;'


  ###*
  # For each line add the @xUnitPrefix and escape special characters in the given string of html.
  #
  # @api private
  # @param  {string} stack
  # @return {string}
  ###
  escapeStack: (stack = "")->

    return stack.split("\n")
      .map( (s) => "##_meteor_magic##xunit: " + @escape(s))
      .join("\n")


module.exports.runTests = ->
  MochaRunner.setReporter(XUnitReporter)