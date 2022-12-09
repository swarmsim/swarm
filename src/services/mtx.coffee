'use strict'
import _ from 'lodash'

###*
###
angular.module('swarmApp').factory 'KongregateMtx', ($q, game, kongregate) -> class KongregateMtx
  constructor: (@buyPacks) ->
    @buyPacksByName = _.keyBy @buyPacks, 'name'
  packs: -> $q (resolve, reject) =>
    #kongregate.kongregate.mtx.requestItemList [], (res) =>
    #  resolve(res)
    # Can't store enough metadata with kong, screw it, use the spreadsheet
    return resolve(@buyPacks)
  pull: -> $q (resolve, reject) =>
    kongregate.onLoad.then =>
      if kongregate.kongregate.services.isGuest()
        return reject 'Please log in to buy crystals.'
      kongregate.kongregate.mtx.requestUserItemList null, (res, error) =>
        try
          if !res.success
            return reject(res)
          changed = false
          for purchase in res.data
            if !game.session.state.mtx?.kongregate?[purchase.id]
              #session.state.mtx.kongregate[purchase.id] = true
              pack = @buyPacksByName[purchase.identifier]
              if pack?
                game.unit('crystal')._addCount pack['pack.val']
                game.session.state.mtx ?= {}
                game.session.state.mtx.kongregate ?= {}
                game.session.state.mtx.kongregate[purchase.id] = true
                changed = true
          resolve({changed: changed})
        catch e
          reject(e)
  buy: (name) -> $q (resolve, reject) =>
    kongregate.onLoad.then =>
      if kongregate.kongregate.services.isGuest()
        return reject 'Please log in to buy crystals.'
      kongregate.kongregate.mtx.purchaseItems [name], (success) =>
        if success
          @pull()
          resolve(success)
        else
          reject(success)

rejectErrors = (reject, name, fn) =>
  try
    return fn()
  catch e
    console.error e
    return reject name+": "+e
# Playfab error checking within a promise.
# usage: PlayFabClientAPI.blah {}, wrapPlayfab reject, 'blah', (result) =>
wrapPlayfab = (reject, name, fn) => (result) =>
  return rejectErrors reject, name, =>
    if !result? or result.status != 'OK'
      return reject result
    return fn result

## Oh fuck this. New problems every time I try to get this working with playfab. Playfab, I love you, but you're not letting me give you money :(
## Dropping playfab for braintree or pure-paypal instead.
#angular.module('swarmApp').factory 'PaypalPlayfabMtx', ($q, $log, game, env, playfab) -> class PaypalPlayfabMtx
#  # Playfab uses Paypal as its backend here
#  constructor: (@buyPacks) ->
#    @buyPacksByName = _.keyBy @buyPacks, 'name'
#  packs: -> $q (resolve, reject) =>
#    # TODO use playfab's item list
#    return resolve(@buyPacks)
#  _confirm: ->
#    orderIds = Object.keys game.session.state.mtx?.paypal?.pendingOrderIds ? {}
#    $log.debug 'playfab/paypal pendingorderids', orderIds, game.session.state.mtx?.paypal?.pendingOrderIds
#    return $q.all orderIds.map (orderId) -> $q (resolve, reject) ->
#      # true is successful past orders, don't retry
#      if game.session.state.mtx.paypal.pendingOrderIds[orderId].success
#        return resolve()
#      PlayFabClientSDK.ConfirmPurchase
#        OrderId: orderId
#        (result, error) =>
#          $log.debug 'PlayFabClientSDK.ConfirmPurchase', result, error, JSON.stringify(result ? error)
#          # https://api.playfab.com/docs/non-receipt-purchasing > transaction states
#          switch result?.data?.Status ? error?.error
#            # succeed and don't retry, we're done
#            when "Succeeded"
#              $log.info 'confirmed order', orderId, result.data.Items
#              game.session.state.mtx.paypal.pendingOrderIds[orderId].success = true
#              game.save()
#              resolve result
#            # incomplete, keep retrying
#            when "CreateCart", "Init", "Approved"
#              resolve result
#            # fail and don't retry, give up
#            when "FailedByProvider", "FailedByPaymentProvider"
#              $log.info 'permanently rejejcted order', orderId
#              delete game.session.state.mtx.paypal.pendingOrderIds[orderId]
#              game.save()
#              reject result
#            # fail but keep retrying
#            when "DisputePending", "RefundPending", "Refunded", "RefundFailed", "ChargedBack", "FailedByPlayfab"
#              reject result
#            else
#              reject result
#
#  pull: -> $q (resolve, reject) =>
#    pullFn = =>
#      PlayFabClientSDK.GetUserInventory {},
#        wrapPlayfab reject, 'GetUserInventory', (result) =>
#          changed = false
#          for item in result.data.Inventory
#            if !game.session.state.mtx?.paypal?.items?[item.ItemInstanceId]?
#              pack = @buyPacksByName[item.ItemId]
#              if pack?
#                $log.debug 'applying pulled crystal pack', item.ItemInstanceId, pack
#                game.unit('crystal')._addCount pack['pack.val']
#                game.session.state.mtx ?= {}
#                game.session.state.mtx.paypal ?= {}
#                game.session.state.mtx.paypal.items ?= {}
#                game.session.state.mtx.paypal.items[item.ItemInstanceId] = true
#                changed = true
#          resolve({changed: changed})
#    playfab.waitForAuth().then(
#      (result) =>
#        @_confirm().then pullFn, pullFn
#        return result
#      (error) => reject(error); return error)
#  buy: (name) -> return p = $q (resolve, reject) =>
#    #popup = window.open()
#    #p.catch (error) ->
#    #  popup.close()
#    #  return error
#    #$log.debug 'paypalCatalogVersion: ', env.paypalCatalogVersion
#    playfab.waitForAuth().then(
#      (result) =>
#        PlayFabClientSDK.StartPurchase
#          CatalogVersion: env.paypalCatalogVersion,
#          Items: [{
#            ItemId: name
#            Quantity: 1
#          }]
#          wrapPlayfab reject, 'StartPurchase', (result) =>
#            PlayFabClientSDK.PayForPurchase
#              OrderId: result.data.OrderId
#              ProviderName: "PayPal"
#              Currency: "RM"
#              wrapPlayfab reject, 'PayForPurchase', (result2) =>
#                game.session.state.mtx ?= {}
#                game.session.state.mtx.paypal ?= {}
#                game.session.state.mtx.paypal.pendingOrderIds = {}
#                game.session.state.mtx.paypal.pendingOrderIds[result2.data.OrderId] = {created: Date.now(), success: false}
#                game.save()
#                if !result2.data?.PurchaseConfirmationPageURL
#                  # This can happen in development with free items. Just re-pull.
#                  $log.warn 'No PurchaseConfirmationPageURL', result2.data?.PurchaseConfirmationPageURL
#                  @pull()
#                  #popup.close()
#                  return resolve()
#                document.location = result2.data.PurchaseConfirmationPageURL
#                #popup.location = result2.data.PurchaseConfirmationPageURL
#                return resolve()
#        return result
#      (error) => reject(error); return error)

# https://www.sandbox.paypal.com/us/cgi-bin/customerprofileweb?cmd=_button-management
# https://www.paypal.com/us/cgi-bin/customerprofileweb?cmd=_button-management
#
# Paypal with minimal Playfab interaction. We use playfab cloudscript to call
# Paypal from a server to verify Paypal success (CORS errors and
# secret-id-exposure trying to do it from the client), but otherwise, no playfab.
angular.module('swarmApp').factory 'PaypalHostedButtonMtx', ($q, $log, $location, game, env, $http, playfab, domainType) -> class PaypalHostedButtonMtx
  constructor: (@buyPacks) ->
    for pack in @buyPacks
      pack.paypalUrl = @_packUrl(pack)
    @buyPacksByName = _.keyBy @buyPacks, 'name'
    @uiStyle = 'paypal'
  _packUrl: (pack) ->
    # overwrite production urls in dev
    if env.isPaypalSandbox
      return pack.paypalSandboxUrl
    # in prod, different return urls for different domains. Sadly, we can't override
    # a paypal hosted button's return url, have to use a whole different button:
    # https://stackoverflow.com/questions/45258956/paypal-is-not-overriding-the-return-url
    if domainType == 'oldwww'
      return pack.paypalLegacyGithubUrl
    return pack.paypalSwarmsimDotComUrl

  packs: -> $q (resolve, reject) =>
    playfab.waitForAuth().then =>
      if !playfab.isAuthed()
        return reject 'Please log in to buy crystals: More... > Options'
      playfabId = playfab.auth.raw.PlayFabId
      if !playfabId
        return reject 'Please try logging in again. (playfab.auth.raw.PlayFabId missing)'
      packs = _.map(@buyPacks, (pack) -> _.assign({}, pack, {
        paypalUrl: pack.paypalUrl+'&custom='+encodeURIComponent(JSON.stringify({playfabId: playfabId})),
      }))
      return resolve(packs)
    .catch (e) =>
      if !playfab.isAuthed()
        return reject 'Please log in to buy crystals: More... > Options'
      return reject e
  _pullInventory: -> $q (resolve, reject) => rejectErrors reject, '_pullInventory', =>
    playfab.waitForAuth().then =>
      PlayFabClientSDK.GetUserInventory {},
        wrapPlayfab reject, 'GetUserInventory', (result) =>
          changed = false
          for item in result.data.Inventory
            if !game.session.state.mtx?.playfab?.items?[item.ItemInstanceId]?
              pack = @buyPacksByName[item.ItemId]
              if pack?
                $log.debug 'applying pulled crystal pack', item.ItemInstanceId, pack
                game.unit('crystal')._addCount pack['pack.val']
                game.session.state.mtx ?= {}
                game.session.state.mtx.playfab?= {}
                game.session.state.mtx.playfab.items ?= {}
                game.session.state.mtx.playfab.items[item.ItemInstanceId] = true
                changed = true
          resolve({changed: changed})
    .catch (e) =>
      if !playfab.isAuthed()
        return reject 'Please log in to buy crystals: More... > Options'
      return reject e
  _pullTransactionId: (tx) -> $q (resolve, reject) => rejectErrors reject, '_pullTransactionId', =>
    #return resolve() # uncommenting this disables PDT. Useful for testing IPN.
    if !tx
      return resolve()
    else
      playfab.waitForAuth().then =>
        if !playfab.isAuthed()
          return reject 'Please log in to buy crystals: More... > Options'
        PlayFabClientSDK.ExecuteCloudScript
          FunctionName: 'paypalNotify'
          FunctionParameter: {tx: tx}
          wrapPlayfab reject, 'ExecuteCloudScript(paypalNotify)', (res) ->
            # way too many possible error conditions here. Sigh.
            if (res.data.Error)
              return reject('paypalNotify.Error: '+JSON.stringify(res.data.Error))
            else if (!res.data.FunctionResult)
              return reject('paypalNotify: '+JSON.stringify(res.data))
            else if (res.data.FunctionResult.state == 'error')
              return reject('paypalNotify.FunctionResult: '+JSON.stringify(res.data.FunctionResult))
            else
              return resolve(res.data.FunctionResult)
      .catch (e) =>
        if !playfab.isAuthed()
          return reject 'Please log in to buy crystals: More... > Options'
        return reject e

  pull: ->
    # Return-from-paypal URLs have a transaction id for us to verify.
    # https://developer.paypal.com/docs/classic/products/payment-data-transfer/
    # https://developer.paypal.com/docs/classic/paypal-payments-standard/integration-guide/paymentdatatransfer/
    return @_pullTransactionId($location.search().tx).then(=> @_pullInventory())

  # no buy() - paypal is an html form submit

angular.module('swarmApp').factory 'DisabledMtx', ($q, game) -> class DisabledMtx
  constructor: ->
    @uiStyle = 'disabled'
  fail: -> $q (resolve, reject) =>
    reject 'PayPal crystal packs are coming soon.'
  packs: -> @fail()
  pull: -> @fail()
  buy: -> @fail()

angular.module('swarmApp').factory 'Mtx', ($q, game, isKongregate, KongregateMtx, DisabledMtx, PaypalHostedButtonMtx) -> class Mtx
  constructor: (buyPacks) ->
    if isKongregate()
      @backend = new KongregateMtx buyPacks
    else
      #@backend = new DisabledMtx()
      @backend = new PaypalHostedButtonMtx buyPacks
  uiStyle: -> @backend.uiStyle || 'normal'
  packs: -> @backend.packs()
  pull: ->
    @backend.pull().then (res) ->
      if res.changed
        game.save()
      return res
  buy: (name) -> @backend.buy(name)

###*
 # @ngdoc service
 # @name swarmApp.mtx
 # @description
 # # mtx
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'mtx', (Mtx, spreadsheet) ->
  new Mtx spreadsheet.data.mtx.elements
