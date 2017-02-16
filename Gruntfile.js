// Generated on 2014-08-02 using generator-angular 0.9.2
'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to recursively match all subfolders:
// 'test/spec/**/*.js'

// https://stackoverflow.com/questions/31846665/grunt-contrib-connect-undefined-is-not-a-function-for-connect-static
var serveStatic = require('serve-static');

module.exports = function (grunt) {

  // Load grunt tasks automatically
  require('load-grunt-tasks')(grunt);

  // Time how long tasks take. Can help when optimizing build times
  require('time-grunt')(grunt);

  // Configurable paths for the application
  var appConfig = {
    app: require('./bower.json').appPath || 'app',
    dist: 'dist'
  };

  var dropboxAppKey = function(configuredKey) {
    var KEYS = {
      shoelaceDev:'6hagxaf8041upxz',
      dev:'q5b8awxy8r3qjus', //account dropbox@swarmsim.com
      prod:'n2mff9wz6bv0f91' //account dropbox@swarmsim.com
    };
    // `--dropboxAppKey=x` can always override this file's configuration
    var key = grunt.option('dropboxAppKey') || configuredKey;
    // key can either be a named key configured above (`--dropboxAppKey=dev`) or the key itself (`--dropboxAppKey=q5b8awxy8r3qjus`)
    return KEYS[key] || key;
  };

  var ngconstant = {
    options: {
      dest: '.tmp/scripts/env.js',
      wrap: '"use strict";\n\n{%= __ngModule %}',
      name: 'swarmEnv',
      constants: {
        version: grunt.file.readJSON('package.json').version
      },
      space: '  '
    },
    test: {
      constants: {
        env: {
          name: 'test',
          isDebugEnabled: true,
          isDebugLogged: false,
          httpsAllowInsecure: true,
          showSkipped: false,
          spreadsheetKey: 'v0.2',
          saveId: '0',
          dropboxAppKey: dropboxAppKey('dev'),
          isDropboxEnabled: true,
          saveServerUrl: grunt.option('saveServerUrl'),
          isKongregateSyncEnabled: true,
          autopushIntervalMs: 1000 * 60 * 9999,
          googleApiKey: 'AIzaSyArP8wzscVTyD4wBWZrhPnGWwj7W7ROaSI',
          isAppcacheEnabled: true,
          playfabTitleId: 'F810',
          sentryDSN: null,
          sentrySampleRate: 0,
          isServerBackendEnabled: true,
          isServerFrontendEnabled: false,
          gaTrackingID: null
        }
      }
    },
    dev: {
      constants: {
        env: {
          name: 'dev',
          isDebugEnabled: true,
          isDebugLogged: true,
          httpsAllowInsecure: true,
          showSkipped: true,
          spreadsheetKey: 'v0.2',
          saveId: 'v0.2',
          dropboxAppKey: dropboxAppKey('dev'),
          isDropboxEnabled: true,
          saveServerUrl: grunt.option('saveServerUrl'),
          isKongregateSyncEnabled: true,
          autopushIntervalMs: 1000 * 15,
          googleApiKey: 'AIzaSyArP8wzscVTyD4wBWZrhPnGWwj7W7ROaSI',
          isAppcacheEnabled: true,
          sentryDSN: 'https://c133b1e19aec40ea8e7641eb94f57004@app.getsentry.com/39317',
          sentrySampleRate: 1,
          // https://developer.playfab.com/en-us/F810/dashboard
          playfabTitleId: 'F810',
          // Everyone's getting server-side accounts.
          //
          // Phase 1: import everything silently/invisibly, no change in
          // behavior, full traffic without inconveniencing players when
          // the server can't scale. Backend release.
          //
          // Phase 2: user accounts now visible. Frontend release.
          //
          // relevant issues: https://github.com/swarmsim/swarm/milestones/pre-1.1
          // enable backend-only (silent release) in prod (phase 1): https://github.com/swarmsim/swarm/issues/586
          isServerBackendEnabled: false,
          isServerFrontendEnabled: false,

          gaTrackingID: 'UA-53523462-3'
        }
      }
    },
    prod: {
      constants: {
        env: {
          name: 'prod',
          isDebugEnabled: false,
          isDebugLogged: false,
          httpsAllowInsecure: false,
          //gaTrackingID: 'UA-53523462-2'
          showSkipped: false,
          spreadsheetKey: 'v0.2',
          saveId: 'v0.2',
          dropboxAppKey: dropboxAppKey('prod'),
          isDropboxEnabled: true,
          saveServerUrl: 'https://api.swarmsim.com',
          isKongregateSyncEnabled: true,
          autopushIntervalMs: 1000 * 60 * 15,
          googleApiKey: 'AIzaSyCS8nqXFvhdr0AR-ox-9n_wKP2std_fHHs',
          // https://developer.playfab.com/en-us/7487/dashboard
          playfabTitleId: '7487',
          isAppcacheEnabled: false,
          sentryDSN: 'https://5b47c35e40a34619954d42f17712eb5f@app.getsentry.com/39331',
          sentrySampleRate: 0.001,
          isServerBackendEnabled: false,
          isServerFrontendEnabled: false,
          gaTrackingID: 'UA-53523462-1'
        }
      }
    },
  };
  ngconstant.preprod = JSON.parse(JSON.stringify(ngconstant.prod));
  ngconstant.preprod.constants.env.saveServerUrl = 'https://api-preprod.swarmsim.com';

  // Define the configuration for all the tasks
  grunt.initConfig({
    // https://www.npmjs.org/package/grunt-gh-pages
    'gh-pages': {
      // no-args/default is staging deployment. 'grunt gh-pages:prod' for production.
      options: {
        base: 'dist'
      },
      src: ['**'],
      default_: {
        // default options
        options: {},
        src: ['**']
      },
      staging: {
        options: {
          branch: 'master',
          repo: 'git@github.com:swarmsim-staging/swarmsim-staging.github.io.git'
        },
        src: ['**']
      },
      preprod: {
        options: {
          user: {
            name: grunt.option('user.name') || null,
            email: grunt.option('user.email') || null,
          },
          branch: 'master',
          repo: 'git@github.com:swarmsim-preprod/swarmsim-preprod.github.io.git'
        },
        src: ['**']
      },
      publictest: {
        options: {
          branch: 'master',
          repo: 'git@github.com:swarmsim-publictest/swarmsim-publictest.github.io.git'
        },
        src: ['**']
      },
      prodDotcom: {
        options: {
          branch: 'master',
          repo: 'git@github.com:swarmsim-dotcom/swarmsim-dotcom.github.io.git'
        },
        src: ['**']
      },
      prodGithubio: {
        options: {
          branch: 'master',
          repo: 'git@github.com:swarmsim/swarmsim.github.io.git'
        },
        src: ['**']
      }
    },

    // http://hounddog.github.io/blog/using-environment-configuration-with-grunt/
    ngconstant: ngconstant,

    preloadSpreadsheet: {
      'v0.2': 'https://docs.google.com/spreadsheets/d/1ughCy983eK-SPIcDYPsjOitVZzY10WdI2MGGrmxzxF4/pubhtml',
    },

    manifest: {
      options: {
        basePath: '<%= yeoman.dist %>',
        cache: [],
        network: ['*', 'http://*', 'https://*',],
        //fallback: ['/ /offline.html'],
        exclude: ['js/jquery.min.js'],
        preferOnline: true,
        verbose: true,
        timestamp: true,
        hash: true,
        master: ['index.html'],
        process: function(path) {
          return path.substring('app/'.length);
        }
      },
      prod: {
        src: [
          'views/*.html',
          'scripts/*.js',
          'styles/*.css'
        ],
        dest: '<%= yeoman.dist %>/manifest.appcache'
      },
      dev: {
        options:{
          basePath: '<%= yeoman.app %>',
        },  
        src: [
          'views/*.html',
          'scripts/*.js',
          'styles/*.css'
        ],
        dest: '.tmp/manifest.appcache'
      }
    },

    // added based on https://github.com/yeoman/generator-angular/pull/277/files
    ngtemplates: {
      dist: {
        options: {
          module: 'swarmApp',
          htmlmin: '<%= htmlmin.dist.options %>',
          usemin: '<%= yeoman.dist %>/scripts/scripts.js'
        },
        cwd: '<%= yeoman.app %>',
        // '**' not grabbing subdirs for some reason, do it manually
        src: ['views/**.html', 'views/playfab/**.html', 'views/desc/unit/**.html', 'views/desc/upgrade/**.html'],
        dest: '.tmp/scripts/templateCache.js'
      },
      // no templates for dev, so they reload properly when changed
      dev: {
        cwd: 'app',
        src: '/dev/null',
        dest: '.tmp/scripts/app.templates.js',
      },
      options: {
        module: 'swarmApp',
        htmlmin: '<%= htmlmin.dist.options %>'
      }
    },

    // Project settings
    yeoman: appConfig,

    // Watches files for changes and runs tasks based on the changed files
    watch: {
      bower: {
        files: ['bower.json'],
        tasks: ['wiredep']
      },
      coffee: {
        files: ['<%= yeoman.app %>/scripts/{,*/}*.{coffee,litcoffee,coffee.md}'],
        //tasks: ['newer:coffee:dist', 'newer:coffee:test', 'karma:unit']
        tasks: ['coffeelint','newer:coffee:dist']
      },
      coffeeTest: {
        files: ['test/spec/{,*/}*.{coffee,litcoffee,coffee.md}'],
        tasks: ['coffeelint','newer:coffee:test', 'karma:unit']
      },
      integrationTest: {
        files: ['test/integration/{,*/}*.{coffee,litcoffee,coffee.md}'],
        tasks: ['coffeelint','newer:coffee:integrationTest', 'karma:integration']
      },
      compass: {
        files: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}'],
        tasks: ['compass:server', 'autoprefixer']
      },
      gruntfile: {
        files: ['Gruntfile.js']
      },
      manifest: {
        files: [ '<%= yeoman.app %>/{,*/}*.html',],
        tasks: [ 'manifest' ]
      },
      livereload: {
        options: {
          livereload: '<%= connect.options.livereload %>'
        },
        files: [
          '<%= yeoman.app %>/{,*/}*.html',
          '.tmp/styles/{,*/}*.css',
          '.tmp/scripts/{,*/}*.js',
          '<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ]
      }
    },

    // The actual grunt server settings
    connect: {
      options: {
        port: process.env.PORT || 9000,
        // Change this to '0.0.0.0' to access the server from outside.
        hostname: '0.0.0.0',
        //livereload: 55728  // ngrok won't bind remote ports below 50000
        livereload: 35728 
      },
      livereload: {
        options: {
          //open: true,
          middleware: function (connect) {
            return [
              serveStatic('.tmp'),
              connect().use(
                '/bower_components',
                serveStatic('./bower_components')
              ),
              serveStatic(appConfig.app)
            ];
          }
        }
      },
      test: {
        options: {
          port: 9001,
          middleware: function (connect) {
            return [
              serveStatic('.tmp'),
              serveStatic('test'),
              connect().use(
                '/bower_components',
                serveStatic('./bower_components')
              ),
              serveStatic(appConfig.app)
            ];
          }
        }
      },
      dist: {
        options: {
          //open: true,
          base: '<%= yeoman.dist %>'
        }
      }
    },

    // Make sure code styles are up to par and there are no obvious mistakes
    jshint: {
      options: {
        jshintrc: '.jshintrc',
        reporter: require('jshint-stylish')
      },
      all: {
        src: [
          'Gruntfile.js'
        ]
      }
    },
    coffeelint: {
    
      options: {
        configFile: 'coffeelint.json'
      },
      app: ['<%= yeoman.app %>/**/*.coffee']
    },

    // Empties folders to start fresh
    clean: {
      dist: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= yeoman.dist %>/{,*/}*',
            '!<%= yeoman.dist %>/.git*'
          ]
        }]
      },
      spreadsheetpreload: 'app/scripts/spreadsheetpreload',
      server: '.tmp'
    },

    // Add vendor prefixed styles
    autoprefixer: {
      options: {
        browsers: ['last 1 version']
      },
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/styles/',
          src: '{,*/}*.css',
          dest: '.tmp/styles/'
        }]
      }
    },

    // Automatically inject Bower components into the app
    wiredep: {
      options: {
        //cwd: '<%= yeoman.app %>'
      },
      app: {
        src: ['<%= yeoman.app %>/index.html'],
        overrides: {
          'lz-string': {
            main: 'libs/lz-string.js'
          },
          'konami-js': {
            main: 'konami.js'
          },
          'mathjs': {
            // default math.min.js breaks uglify? https://github.com/gruntjs/grunt-contrib-uglify/issues/233
            main: 'dist/math.js'
          },
          'decimal.js': {
            main: 'decimal.js'
          },
          'playfab-sdk': {
            main: 'PlayFabSDK/PlayFabClientApi.js'
          },
        },
        ignorePath:  /\.\.\//
      },
      sass: {
        src: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}'],
        ignorePath: /(\.\.\/){1,2}bower_components\//
      }
    },

    // Compiles CoffeeScript to JavaScript
    coffee: {
      options: {
        sourceMap: true,
        sourceRoot: ''
      },
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/scripts',
          src: '{,*/}*.coffee',
          dest: '.tmp/scripts',
          ext: '.js'
        }]
      },
      test: {
        files: [{
          expand: true,
          cwd: 'test/spec',
          src: '{,*/}*.coffee',
          dest: '.tmp/spec',
          ext: '.js'
        }]
      },
      integrationTest: {
        files: [{
          expand: true,
          cwd: 'test/integration',
          src: '{,*/}*.coffee',
          dest: '.tmp/integration',
          ext: '.js'
        }]
      }
    },

    // Compiles Sass to CSS and generates necessary files if requested
    compass: {
      options: {
        sassDir: '<%= yeoman.app %>/styles',
        cssDir: '.tmp/styles',
        generatedImagesDir: '.tmp/images/generated',
        imagesDir: '<%= yeoman.app %>/images',
        javascriptsDir: '<%= yeoman.app %>/scripts',
        fontsDir: '<%= yeoman.app %>/styles/fonts',
        importPath: './bower_components',
        httpImagesPath: '/images',
        httpGeneratedImagesPath: '/images/generated',
        httpFontsPath: '/styles/fonts',
        relativeAssets: false,
        assetCacheBuster: false,
        raw: 'Sass::Script::Number.precision = 10\n'
      },
      dist: {
        options: {
          generatedImagesDir: '<%= yeoman.dist %>/images/generated'
        }
      },
      server: {
        options: {
          debugInfo: true
        }
      }
    },

    // Renames files for browser caching purposes
    filerev: {
      dist: {
        src: [
          '<%= yeoman.dist %>/scripts/{,*/}*.js',
          '<%= yeoman.dist %>/styles/{,*/}*.css',
          '<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}',
          '<%= yeoman.dist %>/styles/fonts/*'
        ]
      }
    },

    // Reads HTML for usemin blocks to enable smart builds that automatically
    // concat, minify and revision files. Creates configurations in memory so
    // additional tasks can operate on them
    useminPrepare: {
      html: '<%= yeoman.app %>/index.html',
      options: {
        dest: '<%= yeoman.dist %>',
        flow: {
          html: {
            steps: {
              js: ['concat', 'uglifyjs'],
              css: ['cssmin']
            },
            post: {}
          }
        }
      }
    },

    // Performs rewrites based on filerev and the useminPrepare configuration
    // js/pattern changes based on https://github.com/yeoman/generator-angular/pull/277/files
    usemin: {
      html: ['<%= yeoman.dist %>/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css'],
      manifest: ['<%= yeoman.dist %>/manifest.appcache'],
      js: ['<%= yeoman.dist %>/scripts/{,*/}*.js'],
      options: {
        assetsDirs: ['<%= yeoman.dist %>','<%= yeoman.dist %>/images'],
        patterns: {
          js: [[/(images\/[^''""]*\.(png|jpg|jpeg|gif|webp|svg))/g, 'Replacing references to images']],
          manifest: [
              //[/(scripts/vendor.js)/, 'Replacing reference to vendor.js'],
              //[/(scripts/main.js)/, 'Replacing reference to main.js'],
              //[/(styles/vendor.css)/, 'Replacing reference to vendor.css'],
              //[/(styles/main.css)/, 'Replacing reference to main.css']
            ]

        }
      }
    },

    // The following *-min tasks will produce minified files in the dist folder
    // By default, your `index.html`'s <!-- Usemin block --> will take care of
    // minification. These next options are pre-configured if you do not wish
    // to use the Usemin blocks.
    // cssmin: {
    //   dist: {
    //     files: {
    //       '<%= yeoman.dist %>/styles/main.css': [
    //         '.tmp/styles/{,*/}*.css'
    //       ]
    //     }
    //   }
    // },
    // uglify: {
    //   dist: {
    //     files: {
    //       '<%= yeoman.dist %>/scripts/scripts.js': [
    //         '<%= yeoman.dist %>/scripts/scripts.js'
    //       ]
    //     }
    //   }
    // },
    // concat: {
    //   dist: {}
    // },

    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.{png,jpg,jpeg,gif}',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },

    svgmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.svg',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },

    htmlmin: {
      dist: {
        options: {
          collapseWhitespace: true,
          conservativeCollapse: true,
          collapseBooleanAttributes: true,
          removeCommentsFromCDATA: true,
          removeOptionalTags: true
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.dist %>',
          src: ['*.html', 'views/{,*/}*.html'],
          dest: '<%= yeoman.dist %>'
        }]
      }
    },

    // ngmin tries to make the code safe for minification automatically by
    // using the Angular long form for dependency injection. It doesn't work on
    // things like resolve or inject so those have to be done manually.
    ngmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/concat/scripts',
          src: '*.js',
          dest: '.tmp/concat/scripts'
        }]
      }
    },

    // Replace Google CDN references
    cdnify: {
      dist: {
        html: ['<%= yeoman.dist %>/*.html']
      }
    },

    // Copies remaining files to places other tasks can use
    copy: {
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.app %>',
          dest: '<%= yeoman.dist %>',
          src: [
            'static/**/*',
            'releasewatch/**/*',
            '*.{ico,png,txt}',
            '.htaccess',
            '*.html',
            '*.svg',
            'views/{,*/}*.html',//'views/desc/unit/{,*/}*.html','views/desc/upgrade/{,*/}*.html',
            'images/{,*/}*.{webp}',
            'fonts/*',
            'storage.swf',
          ]
        }, {
          expand: true,
          cwd: '.tmp/images',
          dest: '<%= yeoman.dist %>/images',
          src: ['generated/*']
        }, {
          //for font-awesome: http://stackoverflow.com/questions/21310382/fontawesome-is-not-working-when-project-is-built-with-grunt
          expand: true,
          dot: true,
          cwd: 'bower_components/font-awesome',
          src: ['fonts/*.*'],
          dest: '<%= yeoman.dist %>'
        }, {
          expand: true,
          cwd: '.',
          src: [
            'archive/**/*',
            'bower_components/bootstrap-sass/assets/fonts/bootstrap/*',
            'bower_components/font-awesome/fonts/*',
            'bower_components/bootswatch/fonts/*',
            'bower_components/bootswatch/*/bootstrap.min.css',
            'bower_components/bootswatch/*/bootstrap.min.css',
            'bower_components/bootswatch/*/thumbnail.png',
            'bower_components/ravenjs/dist/raven.min.js'
          ],
          dest: '<%= yeoman.dist %>'
        }]
      },
      phonegap: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>',
          dest: '<%= yeoman.dist %>',
          src: '*.xml'
        }, {
          dest: '<%= yeoman.dist %>/icon.png',
          src: '<%= yeoman.app %>/images/swarmsim-icon.png'
        }, {
          dest: '<%= yeoman.dist %>/splash.png',
          src: '<%= yeoman.app %>/images/swarmsim-icon.png'
        }]
      },
      styles: {
        expand: true,
        cwd: '<%= yeoman.app %>/styles',
        dest: '.tmp/styles/',
        src: '{,*/}*.css'
      }
    },

    // Run some tasks in parallel to speed up the build process
    concurrent: {
      server: [
        'coffee:dist',
        'compass:server'
      ],
      test: [
        'coffee',
        'compass'
      ],
      dist: [
        'coffee',
        'compass:dist',
        'imagemin',
        'svgmin'
      ]
    },

    // Test settings
    karma: {
      // singleRun is needed or else livereload stops working. boo.
      unit: {
        configFile: 'test/karma-unit.conf.coffee',
        singleRun: true
      },
      integration: {
        configFile: 'test/karma-integration.conf.coffee',
        singleRun: true
      },
      unitCi: {
        configFile: 'test/karma-unit.conf.coffee',
        singleRun: true
      },
      integrationCi: {
        configFile: 'test/karma-integration.conf.coffee',
        singleRun: true
      }
    },
    githash: {
      main: {}
    },
  });

  // Kongregate mtx changed? https://docs.google.com/spreadsheets/d/1ughCy983eK-SPIcDYPsjOitVZzY10WdI2MGGrmxzxF4/export?gid=1404187062&format=csv
  grunt.registerMultiTask('preloadSpreadsheet', 'Update spreadsheet data', function () {
    var Tabletop = require('tabletop');
    var stringify = require('json-stable-stringify');
    var _ = require('lodash');

    var directory = 'app/scripts/spreadsheetpreload/';
    var url = this.data;
    var key = this.target;
    
    var done = this.async();
    Tabletop.init({
      key: url,
      parseNumbers: true,
      debug: true,
      callback: function (data) {
        data = _.pick(data, ['unittypes', 'upgrades', 'achievements', 'tutorial', 'mtx', 'mtx.playfabUpload']);
        data = _.mapValues(data, function(sheet) {
          return _.omit(sheet, ['raw']);
        });

        //var text = JSON.stringify(data, null, 2);
        // built-in stringify puts sheets in a random order. Use a consistent
        // order with json-stable-stringify for cleaner diffs.
        var keys = function(data) {
          var ret = [];
          for (var key in data) {
            if (data.hasOwnProperty(key)) {
              ret.push(key);
            }
          }
          return ret;
        };
        for (var sheetname in data) {
          data[sheetname] = _.pick(data[sheetname], ['column_names', 'elements', 'name']);
        }

        // special case playfab uploads. Two files: main and free (zero-cost, for testing)
        var playfab = {
          CatalogVersion: 'beta',
          Catalog: data['mtx.playfabUpload'].elements,
        };
        delete data['mtx.playfabUpload']
        for (var i=0; i < playfab.Catalog.length; i++) {
          var row = playfab.Catalog[i];
          // this part's messy
          //row.VirtualCurrencyPrices = {RM: 0}
          row.VirtualCurrencyPrices = {RM: row['VirtualCurrencyPrices.RM']}
          delete row['VirtualCurrencyPrices.RM']
        }
        var playfabFile = directory + key + '.playfabUpload.beta.js';
        grunt.file.write(playfabFile, stringify(playfab, {space:'  '}));
        console.log('Wrote '+playfabFile);

        playfab.CatalogVersion = 'free';
        for (var i=0; i < playfab.Catalog.length; i++) {
          playfab.Catalog[i].DisplayName += ' (free)'
          playfab.Catalog[i].VirtualCurrencyPrices.RM = 0;
        }
        playfabFile = directory + key + '.playfabUpload.free.js';
        grunt.file.write(playfabFile, stringify(playfab, {space:'  '}));
        console.log('Wrote '+playfabFile);

        // end playfab; back to everything else
        var text = stringify(data, {space:'  '});
        text = '// This is an automatically generated file! Do not edit!\n// Edit the source at: '+url+'\n// Generated by Gruntfile.js:preloadSpreadsheet\n// key: '+key+'\n\'use strict\';\n\ntry {\n  angular.module(\'swarmSpreadsheetPreload\');\n  //console.log(\'second'+key+'\');\n}\ncatch (e) {\n  // module not yet initialized by some other module, we\'re the first\n  angular.module(\'swarmSpreadsheetPreload\', []);\n  //console.log(\'first'+key+'\');\n}\nangular.module(\'swarmSpreadsheetPreload\').value(\'spreadsheetPreload-'+key+'\', '+text+');';
        var filename = directory + key + '.js';
        grunt.file.write(filename, text);
        console.log('Wrote '+filename);
        done();
      }
    });
  });
  grunt.registerTask('writeVersionJson', 'write version info to a json file', ['githash', '_writeVersionJson', 'preloadSpreadsheet']);
  grunt.registerTask('_writeVersionJson', 'write version info to a json file', function() {
    var version = grunt.file.readJSON('package.json').version;
    var data = {
      version: version,
      updated: new Date(),
      githash: grunt.config('githash.main'),
    };
    var text = JSON.stringify(data, undefined, 2);
    grunt.file.write('.tmp/version.json', text);
    grunt.file.write('dist/version.json', text);
  });
  grunt.registerTask('buildCname', 'build swarmsim.com cname file', function () {
    grunt.file.write('dist/CNAME', 'www.swarmsim.com');
  });
  grunt.registerTask('stagingCname', 'build staging.swarmsim.com cname file', function () {
    grunt.file.write('dist/CNAME', 'staging.swarmsim.com');
  });
  grunt.registerTask('preprodCname', 'build preprod.swarmsim.com cname file', function () {
    grunt.file.write('dist/CNAME', 'preprod.swarmsim.com');
  });
  grunt.registerTask('publictestCname', 'build beta.swarmsim.com cname file', function () {
    grunt.file.write('dist/CNAME', 'beta.swarmsim.com');
  });
  grunt.registerTask('cleanCname', 'build swarmsim.com cname file', function () {
    grunt.file.delete('dist/CNAME');
  });
  grunt.registerTask('ss', 'Preload spreadsheet data and save to .tmp', function () {
    grunt.task.run(['preloadSpreadsheet']);
  });

  grunt.registerTask('serve', 'Compile then start a connect web server', function (target) {
    if (target === 'dist') {
      return grunt.task.run(['build', 'connect:dist:keepalive']);
    }
    if (target === 'prod') {
      grunt.task.run([
        'clean:server',
        //'mxmlc:prod',
        'ngconstant:prod','writeVersionJson', 'ngtemplates:dist',
        'manifest:prod',
        'wiredep', 
        'concurrent:server',
        'autoprefixer',
        'connect:livereload',
        'watch'
      ]);
    }

    grunt.task.run([
      'clean:server',
      //'mxmlc:dev',
      'ngconstant:dev','writeVersionJson', 'ngtemplates:dev',
      'manifest:dev',
      'wiredep',
      'concurrent:server',
      'autoprefixer',
      'connect:livereload',
      'watch'
    ]);
  });

  grunt.registerTask('server', 'DEPRECATED TASK. Use the "serve" task instead', function (target) {
    grunt.log.warn('The `server` task has been deprecated. Use `grunt serve` to start a server.');
    grunt.task.run(['serve:' + target]);
  });

  grunt.registerTask('test', [
    'clean:server',
    'ngconstant:test','writeVersionJson', 'ngtemplates:dev',
    'concurrent:test',
    'autoprefixer',
    'connect:test',
    'coffeelint',
    'karma:unitCi',
    'karma:integrationCi'
  ]);

  grunt.registerTask('build', function(envname) {
    envname = envname || 'prod';
    if (envname != 'prod' && envname != 'preprod') {
      throw new Error('invalid build envname: '+envname);
    }
    console.log('building envname '+envname);
    grunt.task.run([
      'clean:dist',
      'ngconstant:'+envname,'writeVersionJson',
      'wiredep',
      'useminPrepare',
      'concurrent:dist',
      'ngtemplates:dist',
      'autoprefixer',
      'concat',
      'ngmin',
      'copy:dist',
      'cdnify',
      'cssmin',
      'uglify',
      'filerev',
      'manifest',
      'usemin',
      'htmlmin',
      // mxmlc stopped working at some point, but I can't be bothered to fix it properly.
      // The compiled version is now saved in git, so we'll just use that and remove all
      // flash deps from the build.
      //'mxmlc:prod'
    ]);
  });

  grunt.registerTask('default', [
    'newer:jshint',
    'test',
    'build'
  ]);

  grunt.registerTask('deploy-staging', [
    'build',
    'stagingCname','gh-pages:staging','cleanCname'
  ]);
  grunt.registerTask('deploy-preprod', [
    'build:preprod',
    'preprodCname','gh-pages:preprod','cleanCname'
  ]);
  grunt.registerTask('deploy-publictest', [
    'build',
    'publictestCname','gh-pages:publictest','cleanCname'
  ]);
  grunt.registerTask('phonegap-staging', [
    'build',
    'copy:phonegap',
    'stagingCname','gh-pages:staging','cleanCname'
  ]);
  grunt.registerTask('deploy-prod-dotcom', [
    'build',
    'buildCname','gh-pages:prodDotcom','cleanCname'
  ]);
  grunt.registerTask('deploy-prod-githubio', [
    'build',
    'cleanCname','gh-pages:prodGithubio',
  ]);
  grunt.registerTask('deploy-prod', [
    'build',
    'cleanCname','gh-pages:prodGithubio',
    'buildCname','gh-pages:prodDotcom','cleanCname'
  ]);
};
