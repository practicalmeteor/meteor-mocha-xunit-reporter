Package.describe({
  name: 'practicalmeteor:mocha-xunit-reporter',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/practicalmeteor/meteor-mocha-xunit-reporter.git',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md',
  testOnly: true
}); 

Package.onUse(function(api) {
  api.versionsFrom('1.3');
  api.use("coffeescript");
  api.use("practicalmeteor:mocha");
  api.use('ecmascript');

  api.mainModule('XunitReporter.coffee');
  api.export("runTests")
});

Package.onTest(function(api) {
  api.use('ecmascript');
  api.use('tinytest');
  api.use('packages');
  api.mainModule('packages-tests.js');
});
