'use strict'

###*
###
angular.module('swarmApp').factory 'KongregateMtx', ($q, game, kongregate) -> class KongregateMtx
  constructor: (@buyPacks) ->
    @currency = 'kreds'
    @buyPacksByName = _.keyBy @buyPacks, 'name'
  packs: -> $q (resolve, reject) =>
    #kongregate.kongregate.mtx.requestItemList [], (res) =>
    #  resolve(res)
    # Can't store enough metadata with kong, screw it, use the spreadsheet
    return resolve(@buyPacks)
  pull: -> $q (resolve, reject) =>
    kongregate.onLoad.then =>
      if kongregate.kongregate.services.isGuest()
        reject 'Please log in to buy crystals.'
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
        reject 'Please log in to buy crystals.'
      kongregate.kongregate.mtx.purchaseItems [name], (success) =>
        if success
          @pull()
          resolve(success)
        else
          reject(success)

# Playfab error checking within a promise.
# usage: PlayFabClientAPI.blah {}, wrapPlayfab reject, 'blah', (result) =>
wrapPlayfab = (reject, name, fn) => (result) =>
  try
    console.debug 'PlayFabClientSDK.'+name, result
    if !result? or result.status != 'OK'
      return reject result
    return fn result
  catch e
    console.error e
    reject e
 
# https://community.playfab.com/questions/638/208252737-PlayFab-and-PayPal-integration-problem.html
angular.module('swarmApp').factory 'PaypalMtx', ($q, $log, game, env) -> class PaypalMtx
  # Playfab uses Paypal as its backend here
  constructor: (@buyPacks) ->
    @currency = 'usd_paypal'
    @buyPacksByName = _.keyBy @buyPacks, 'name'
  packs: -> $q (resolve, reject) =>
    # TODO use playfab's item list
    return resolve(@buyPacks)
  _confirm: ->
    orderIds = Object.keys game.session.state.mtx?.paypal?.pendingOrderIds ? {}
    console.debug 'playfab/paypal pendingorderids', orderIds
    return $q.all orderIds.map (orderId) -> $q (resolve, reject) ->
      # true is successful past orders, don't retry
      if game.session.state.mtx.paypal.pendingOrderIds[orderId]
        return resolve()
      PlayFabClientSDK.ConfirmPurchase
        OrderId: orderId
        (result) =>
          console.debug 'PlayFabClientSDK.ConfirmPurchase', result
          # https://api.playfab.com/docs/non-receipt-purchasing > transaction states
          switch result.data?.Status?
            # succeed and don't retry, we're done
            when "Succeeded"
              console.log 'confirmed order', orderId, result.data.Items
              game.session.state.mtx.paypal.pendingOrderIds[orderId] = true
              resolve result
            # incomplete, keep retrying
            when "CreateCart", "Init", "Approved"
              resolve result
            # fail and don't retry, give up
            when "FailedByProvider"
              console.log 'permanently rejejcted order', orderId
              delete game.session.state.mtx.paypal.pendingOrderIds[orderId]
              reject result
            # fail but keep retrying
            when "DisputePending", "RefundPending", "Refunded", "RefundFailed", "ChargedBack", "FailedByPlayfab"
              reject result
            else
              reject result
    
  pull: -> $q (resolve, reject) =>
    pullFn = =>
      PlayFabClientSDK.GetUserInventory {},
        wrapPlayfab reject, 'GetUserInventory', (result) =>
          changed = false
          for item in result.data.Inventory
            if !game.session.state.mtx?.paypal?.items?[item.ItemInstanceId]?
              pack = @buyPacksByName[item.ItemId]
              if pack?
                console.debug 'applying pulled crystal pack', item.ItemInstanceId, pack
                game.unit('crystal')._addCount pack['pack.val']
                game.session.state.mtx ?= {}
                game.session.state.mtx.paypal ?= {}
                game.session.state.mtx.paypal.items ?= {}
                game.session.state.mtx.paypal.items[item.ItemInstanceId] = true
                changed = true
          resolve({changed: changed})
    @_confirm().then pullFn, pullFn
  buy: (name) -> $q (resolve, reject) =>
    $log.debug 'paypalCatalogVersion: ', env.paypalCatalogVersion
    PlayFabClientSDK.StartPurchase
      CatalogVersion: env.paypalCatalogVersion,
      Items: [{
        ItemId: name
        Quantity: 1
      }]
      wrapPlayfab reject, 'StartPurchase', (result) =>
        PlayFabClientSDK.PayForPurchase
          OrderId: result.data.OrderId
          ProviderName: "PayPal"
          Currency: "RM"
          wrapPlayfab reject, 'PayForPurchase', (result) =>
            game.session.state.mtx ?= {}
            game.session.state.mtx.paypal ?= {}
            game.session.state.mtx.paypal.pendingOrderIds = {}
            game.session.state.mtx.paypal.pendingOrderIds[result.data.OrderId] = true
            game.save()
            if !result.data?.PurchaseConfirmationPageURL
              # This can happen in development with free items. Just re-pull.
              console.warn 'No PurchaseConfirmationPageURL', result.data?.PurchaseConfirmationPageURL
              @pull()
              return resolve()
            document.location = result.data.PurchaseConfirmationPageURL

angular.module('swarmApp').factory 'DisabledMtx', ($q, game) -> class KongregateMtx
  fail: -> $q (resolve, reject) =>
    reject 'PayPal crystal packs are coming soon.'
  packs: -> @fail()
  pull: -> @fail()
  buy: -> @fail()

angular.module('swarmApp').factory 'Mtx', ($q, game, isKongregate, KongregateMtx, PaypalMtx, DisabledMtx) -> class Mtx
  constructor: (buyPacks) ->
    if isKongregate()
      @backend = new KongregateMtx buyPacks
    else
      #@backend = new DisabledMtx()
      @backend = new PaypalMtx buyPacks
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
