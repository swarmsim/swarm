'use strict'

###*
 # @ngdoc service
 # @name swarmApp.spreadsheetutil
 # @description
 # # spreadsheetutil
 # Factory in the swarmApp.
###
angular.module('swarmApp').factory 'spreadsheetUtil', -> new class SpreadsheetUtil
  defaultFilter: (val) ->
    # zero, or any truthy value
    !!val or _.isNumber val

  setNested: (object, props, val) ->
    [props..., lastprop] = props
    cur = object
    for prop in props
      cur[prop] ?= {}
      cur = cur[prop]
    cur[lastprop] = val
    return object

  getNested: (object, props) ->
    cur = object
    for prop in props
      cur = cur[prop]
    return cur
  
  normalizeRow: (row, filterFn=@defaultFilter) ->
    ret = {}
    for col, val of row
      if filterFn val
        props = col.split '.'
        @setNested ret, props, val
    return ret

  normalizeRows: (rows, filterFn=@defaultFilter) ->
    (@normalizeRow(row, filterFn) for row in rows)

  # Group row properties as lists, given a spec saying how to group them.
  # {a:['list']}, [{a:'bob',list:1},{a:'bob',list:2}] -> [{a:'bob',list:[1,2]}]
  # In the example above, 'a' is the primary key. Different primary keys aren't
  # grouped. See the unittest for more examples.
  # Empty values filtered by default.
  groupRows: (groupSpec, rows, filterFn=@defaultFilter) ->
    ret = []
    for key, listProps of groupSpec
      groups = _.groupBy rows, key
      orderedKeyvals = _.uniq _.map rows, key
      if _.isString listProps
        listProps = [listProps]
      if not _.isArray listProps
        # TODO nested groupings
        throw new Error "groupRows: nested groupings not supported yet"
      for keyval in orderedKeyvals
        group = groups[keyval]
        ret.push mainrow = _.clone group[0]
        for listProp in listProps
          listvals = _.pluck group, listProp
          mainrow[listProp] = _.filter listvals, filterFn
    return ret

  parseRows: (groupSpec, rows, filterFn=@defaultFilter) ->
    @groupRows groupSpec, (@normalizeRows rows, filterFn), filterFn

  resolveList: (objects, field, targets) ->
    console.log 'resolvelist', objects, field
    for obj in objects
      name = obj[field]
      obj[field] = targets[name]
      console.assert obj[field], "couldn't resolve ref: #{obj}.#{field}=#{name}"
