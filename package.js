Package.describe({
  name: 'practicalmeteor:mocha-xunit-reporter',
  version: '0.1.0-rc.1',
  // Brief, one-line summary of the package.
  summary: 'XUnit reporter for mocha',
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
  api.use("practicalmeteor:mocha-console-runner@0.2.1-rc.2");
  api.use('ecmascript');

  api.mainModule('XunitReporter.coffee', 'client');
  api.export("runTests")
});

Package.onTest(function(api) {

});
