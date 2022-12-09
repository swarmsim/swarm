/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
'use strict';

describe('Service: spreadsheetutil', function() {

  // load the service's module
  beforeEach(module('swarmApp'));

  // instantiate service
  let spreadsheetUtil = {};
  beforeEach(inject(_spreadsheetUtil_ => spreadsheetUtil = _spreadsheetUtil_)
  );

  it('should do something', () => expect(!!spreadsheetUtil).toBe(true));

  it('sets nested properties', function() {
    expect(spreadsheetUtil.setNested({}, ['one'], 'two')).toEqual({one:'two'});
    return expect(spreadsheetUtil.setNested({}, ['one','two','three'], 'four')).toEqual({one:{two:{three:'four'}}});
});

  it('gets nested properties', () => expect(spreadsheetUtil.getNested({one:{two:'three'}}, ['one','two'])).toEqual('three'));

  it('normalizes single rows', function() {
    expect(spreadsheetUtil.normalizeRow({one:'two'})).toEqual({one:'two'});
    expect(spreadsheetUtil.normalizeRow({one:'two',three:'four'})).toEqual({one:'two',three:'four'});
    return expect(spreadsheetUtil.normalizeRow({one:'two','three.four.five':'six'})).toEqual({one:'two',three:{four:{five:'six'}}});
});

  it('normalizes multiple rows', function() {
    expect(spreadsheetUtil.normalizeRows([])).toEqual([]);
    expect(spreadsheetUtil.normalizeRows([{one:'two'}])).toEqual([{one:'two'}]);
    return expect(spreadsheetUtil.normalizeRows([{one:'two'}, {one:'two','three.four.five':'six'}])).toEqual([{one:'two'},{one:'two',three:{four:{five:'six'}}}]);
});

  return it('groups rows', function() {
    expect(spreadsheetUtil.groupRows({name:'list'}, [
      {name:'bob',list:'one',label:'Bob'},
      {name:'bob',list:'two'},
      {name:'jim',list:''}
    ])).toEqual([
      {name:'bob',list:['one','two'],label:'Bob'},
      {name:'jim',list:[]}
    ]);
    return expect(spreadsheetUtil.groupRows({name:['list','list2']}, [
      {name:'bob',list:'one',list2:'three',label:'Bob'},
      {name:'bob',list:'two',list2:'four'},
      {name:'bob',list:''},
      {name:'jim',list:''}
    ])).toEqual([
      {name:'bob',list:['one','two'],list2:['three','four'],label:'Bob'},
      {name:'jim',list:[], list2:[]}
    ]);
});
});

