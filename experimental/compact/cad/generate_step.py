import sys, math
from pathlib import Path
import cadquery as cq
from cadquery import Vector
C=299792.458

def make(antenna, part):
 f,turns=(635,4.2) if antenna==0 else (860,5.65)
 pitch=C/f/4; wire=4.; rad=C/f/(2*math.pi); outer=rad-wire*.25; inner=outer-3; h=turns*pitch/3; bottom=5.; joint=12.; gap=.25
 start=0 if part==0 else bottom+part*h
 end=bottom+(part+1)*h
 height=end-start
 body=cq.Workplane('XY').circle(outer).extrude(height)
 cavity_z=max(bottom-start,0)
 cavity=cq.Workplane('XY').workplane(offset=cavity_z).circle(inner).extrude(height-cavity_z+1)
 body=body.cut(cavity)
 if part==0:
  body=body.cut(cq.Workplane('XY').workplane(offset=-1).circle(3.25).extrude(bottom+2))
 if part<2:
  spigot=cq.Workplane('XY').workplane(offset=height-.15).circle(inner-gap).circle(inner-gap-3).extrude(joint+.15)
  bridge=cq.Workplane('XY').workplane(offset=height-1).circle(inner+.8).circle(inner-gap-3).extrude(1.5)
  body=body.union(spigot).union(bridge)
 # extend groove beyond section ends to allow matching groove phases
 gz0=max(bottom,start-3); gz1=min(bottom+turns*pitch,end+3)
 rel0=gz0-start; phase=360*(gz0-bottom)/pitch
 path=cq.Wire.makeHelix(pitch,gz1-gz0,rad,center=Vector(0,0,rel0))
 profile=cq.Workplane('XZ',origin=(0,0,rel0)).center(rad,0).circle((wire+.35)/2)
 cutter=profile.sweep(path,isFrenet=True).rotate((0,0,0),(0,0,1),phase)
 body=body.cut(cutter)
 solid=body.val(); print('build',antenna,part,'valid',solid.isValid(),'solids',len(body.solids().vals()),flush=True)
 if not solid.isValid() or len(body.solids().vals())!=1: raise RuntimeError('Invalid model')
 name=str(Path(__file__).resolve().parent.parent / 'step' / f'kompas_{antenna}_section_{part+1}.step')
 cq.exporters.export(body,name)
 imported=cq.importers.importStep(name); s=imported.val(); print('verify',name,'valid',s.isValid(),'solids',len(imported.solids().vals()),'height',round(s.BoundingBox().zlen,3),flush=True)
 if not s.isValid() or len(imported.solids().vals())!=1: raise RuntimeError('Invalid STEP')
for a in (0,1):
 for p in (0,1,2): make(a,p)
