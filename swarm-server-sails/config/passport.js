/**
 * Passport configuration
 *
 * This is the configuration for your Passport.js setup and where you
 * define the authentication strategies you want your application to employ.
 *
 * I have tested the service with all of the providers listed below - if you
 * come across a provider that for some reason doesn't work, feel free to open
 * an issue on GitHub.
 *
 * Also, authentication scopes can be set through the `scope` property.
 *
 * For more information on the available providers, check out:
 * http://passportjs.org/guide/providers/
 */

module.exports.passport = {
  local: {
    strategy: require('passport-local').Strategy
  },
  kongregate: {
    name: 'Kongregate',
    strategy: require('../lib/passport-kongregate/strategy'),
    protocol: 'kongregate',
    options: {
      // TODO remove default, it's there for tests
      apiKey: process.env.KONREGATE_API_KEY || ''
    }
  },

  //bearer: {
  //  strategy: require('passport-http-bearer').Strategy
  //},

  //twitter: {
  //  name: 'Twitter',
  //  protocol: 'oauth',
  //  strategy: require('passport-twitter').Strategy,
  //  options: {
  //    consumerKey: 'your-consumer-key',
  //    consumerSecret: 'your-consumer-secret'
  //  }
  //},

  //github: {
  //  name: 'GitHub',
  //  protocol: 'oauth2',
  //  strategy: require('passport-github').Strategy,
  //  options: {
  //    clientID: 'your-client-id',
  //    clientSecret: 'your-client-secret'
  //  }
  //},

  //facebook: {
  //  name: 'Facebook',
  //  protocol: 'oauth2',
  //  strategy: require('passport-facebook').Strategy,
  //  options: {
  //    clientID: 'your-client-id',
  //    clientSecret: 'your-client-secret',
  //    scope: ['email'] /* email is necessary for login behavior */
  //  }
  //},

  //google: {
  //  name: 'Google',
  //  protocol: 'oauth2',
  //  strategy: require('passport-google-oauth').OAuth2Strategy,
  //  options: {
  //    clientID: 'your-client-id',
  //    clientSecret: 'your-client-secret'
  //  }
  //},

  //cas: {
  //  name: 'CAS',
  //  protocol: 'cas',
  //  strategy: require('passport-cas').Strategy,
  //  options: {
  //    ssoBaseURL: 'http://your-cas-url',
  //    serverBaseURL: 'http://localhost:1337',
  //    serviceURL: 'http://localhost:1337/auth/cas/callback'
  //  }
  //}
};
