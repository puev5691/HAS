import test from 'node:test';
import assert from 'node:assert/strict';
import {calculateGeometry,createCalculationExport,DEFAULT_PARAMETERS} from '../geometry.js';
const near=(a,b,tolerance=1e-12)=>assert.ok(Math.abs(a-b)<tolerance,`${a} differs from ${b}`);
test('independent 1 GHz reference geometry from research',()=>{
  const g=calculateGeometry(DEFAULT_PARAMETERS);
  near(g.wavelengthM,0.299792458);near(g.diameterM,0.09542690318473884);
  near(g.spacingM,0.06921254249154635);near(g.axialLengthM,0.5537003399323708);near(g.wireLengthM,2.4614258490470227);
});
test('doubling frequency halves physical dimensions at fixed electrical proportions',()=>{
  const a=calculateGeometry(DEFAULT_PARAMETERS),b=calculateGeometry({...DEFAULT_PARAMETERS,frequencyMHz:2000});
  for(const key of ['wavelengthM','diameterM','circumferenceM','spacingM','axialLengthM','wireLengthM'])near(a[key],2*b[key]);
});
test('turn count changes only total axial and wire lengths',()=>{
  const a=calculateGeometry({...DEFAULT_PARAMETERS,turns:4}),b=calculateGeometry({...DEFAULT_PARAMETERS,turns:8});
  near(a.spacingM,b.spacingM);near(b.axialLengthM,2*a.axialLengthM);near(b.wireLengthM,2*a.wireLengthM);
});
test('invalid, missing and fractional inputs are rejected rather than emitting stale results',()=>{
  for(const bad of [{frequencyMHz:0},{frequencyMHz:NaN},{frequencyMHz:Infinity},{frequencyMHz:30001},{turns:2.5},{turns:0},{turns:31},{circumferenceRatio:0},{circumferenceRatio:1.51},{pitchDeg:0},{pitchDeg:31},{pitchDeg:undefined}])assert.throws(()=>calculateGeometry({...DEFAULT_PARAMETERS,...bad}),RangeError);
});
test('all admitted boundary combinations produce finite positive lengths',()=>{
  for(const frequencyMHz of [1,30000])for(const turns of [1,30])for(const circumferenceRatio of [.05,1.5])for(const pitchDeg of [3,30]){
    const g=calculateGeometry({frequencyMHz,turns,circumferenceRatio,pitchDeg});
    for(const key of ['wavelengthM','diameterM','circumferenceM','spacingM','axialLengthM','wireLengthM'])assert.ok(Number.isFinite(g[key])&&g[key]>0);
    assert.ok(g.wireLengthM>g.axialLengthM);
  }
});
test('export preserves parameters, SI units and model limitations without RF performance claims',()=>{
  const data=createCalculationExport(DEFAULT_PARAMETERS);
  assert.deepEqual(data.input,DEFAULT_PARAMETERS);assert.equal(data.resultUnits.includes('метрах'),true);
  assert.equal(data.equations.length,6);assert.ok(data.exclusions.length>=3);
  assert.equal('gain' in data.result,false);assert.equal('swr' in data.result,false);
});
