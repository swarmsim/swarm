# Karma configuration
# http://karma-runner.github.io/0.12/config/configuration-file.html
# Generated on 2014-08-02 using
# generator-karma 0.8.3

module.exports = (config) ->
  config.set
    # game:build-all-upgrades test needs the extra time
    browserNoActivityTimeout: 30000

    # base path, that will be used to resolve files and exclude
    basePath: '../'

    # testing framework to use (jasmine/mocha/qunit/...)
    frameworks: ['jasmine']

    # list of files / patterns to load in the browser
    files: [
      'node_modules/phantomjs-polyfill/bind-polyfill.js' # phantomjs is missing .bind(). this must go first!
      'bower_components/angular/angular.js'
      'bower_components/angular-hotkeys/build/hotkeys.js' # order matters here, though hell if I know why
      'bower_components/angular-mocks/angular-mocks.js'
      'bower_components/angular-animate/angular-animate.js'
      'bower_components/angular-cookies/angular-cookies.js'
      'bower_components/angular-resource/angular-resource.js'
      'bower_components/angular-route/angular-route.js'
      'bower_components/angular-sanitize/angular-sanitize.js'
      'bower_components/angular-touch/angular-touch.js'
      'bower_components/lodash/lodash.js'
      'bower_components/moment/moment.js'
      'bower_components/angulartics/src/angulartics.js'
      'bower_components/angulartics-google-analytics/dist/angulartics-ga.min.js'
      'bower_components/sjcl/sjcl.js'
      'bower_components/mathjs/dist/math.js'
      'bower_components/lz-string/libs/lz-string.min.js'
      'bower_components/numeral/numeral.js'
      'bower_components/konami-js/konami.js'
      'bower_components/jquery/dist/jquery.js'
      'bower_components/favico.js/favico.js'
      'bower_components/seedrandom/seedrandom.js'
      'bower_components/decimal.js/decimal.js'
      'bower_components/moment-duration-format/lib/moment-duration-format.js'
      'bower_components/jquery-cookie/jquery.cookie.js'
      'bower_components/flash-cookies/dist/swfstore.min.js'
      'bower_components/appcache-nanny/appcache-nanny.js'
      'bower_components/angular-google-chart/ng-google-chart.js'
      'bower_components/playfab-sdk/PlayFabSdk/src/PlayFab/PlayFabClientApi.js'
      'bower_components/swarm-persist/dist/swarm-persist.js'
      'bower_components/swarm-numberformat/dist/swarm-numberformat.js'
      'node_modules/@swarmsim/tables/dist/index.js'
      'app/scripts/**/*.coffee'
      'app/scripts/**/*.js'
      '.tmp/scripts/env.js'
      'test/mock/**/*.coffee'
      'test/integration/**/*.coffee'
    ],

    # list of files / patterns to exclude
    exclude: []

    # web server port
    port: 8080

    # level of logging
    # possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO

    # Start these browsers, currently available:
    # - Chrome
    # - ChromeCanary
    # - Firefox
    # - Opera
    # - Safari (only Mac)
    # - PhantomJS
    # - IE (only Windows)
    browsers: [
      'PhantomJS'
    ]

    # Which plugins to enable
    plugins: [
      'karma-phantomjs-launcher'
      'karma-jasmine'
      'karma-coffee-preprocessor'
    ]

    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true

    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: false

    colors: true

    preprocessors: '**/*.coffee': ['coffee']

    # Uncomment the following lines if you are using grunt's server to run the tests
    # proxies: '/': 'http://localhost:9000/'
    # URL root prevent conflicts with the site root
    # urlRoot: '_karma_'
