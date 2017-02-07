'use strict'

angular.module('swarmApp').factory 'Mtx', ($q, game, kongregate) -> class Mtx
  constructor: (@buyPacks, @toEnergy) ->
    @buyPacksByName = _.keyBy @buyPacks, 'name'
  packs: -> $q (resolve, reject) =>
    #if kongregate.isKongregate()
    #  kongregate.kongregate.mtx.requestItemList [], (res) =>
    #    console.log('kongregate.requestitemlist', res)
    #    resolve(res)
    #else
    #  return resolve(@buyPacks)
    # TODO use kongregate's item list
    return resolve(@buyPacks)
  pull: () ->
    kongregate.kongregate.mtx.requestUserItemList [], (res) =>
      try
        #console.log('useritemlist', res, game.session.state.mtx.kongregate)
        changed = false
        for purchase in res.data
          if !game.session.state.mtx?.kongregate?[purchase.id]
            #session.state.mtx.kongregate[purchase.id] = true
            # TODO use kongregate's item list
            pack = @buyPacksByName[purchase.identifier]
            console.log('!!', pack, purchase)
            if pack?
              game.unit('crystal')._addCount pack['pack.val']
              game.session.state.mtx ?= {}
              game.session.state.mtx.kongregate ?= {}
              game.session.state.mtx.kongregate[purchase.id] = true
              changed = true
        if changed
          game.save()
      catch e
        console.error '!',e
  buy: (name) ->
    kongregate.kongregate.mtx.purchaseItems [name], (success) =>
      if success
        console.log('bought', success)
        @pull()
  convert: (conversion) ->
    crystal = game.unit('crystal')
    energy = game.unit('energy')
    # TODO and energy below total
    if (crystal.count()).greaterThan(conversion.crystal)
      crystal._subtractCount conversion.crystal
      energy._addCount conversion.energy

###*
 # @ngdoc service
 # @name swarmApp.mtx
 # @description
 # # mtx
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'mtx', (Mtx, spreadsheet) ->
  new Mtx spreadsheet.data.mtx.elements, spreadsheet.data.mtxToEnergy.elements
