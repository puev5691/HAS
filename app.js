import {calculateGeometry,createCalculationExport,DEFAULT_PARAMETERS} from './geometry.js';

const $=id=>document.getElementById(id);
const inputs={frequencyMHz:$('frequency'),turns:$('turns'),circumferenceRatio:$('circumference'),pitchDeg:$('pitch')};
const formatter=new Intl.NumberFormat('ru-RU',{maximumFractionDigits:2});
let lastValidParameters={...DEFAULT_PARAMETERS};
function getStorage(key){try{return localStorage.getItem(key)}catch{return null}}
function setStorage(key,value){try{localStorage.setItem(key,value)}catch{}}
function showToast(message){$('toast').textContent=message;$('toast').hidden=false;clearTimeout(showToast.timer);showToast.timer=setTimeout(()=>$('toast').hidden=true,3200)}
function formatLength(m){return m>=10?formatter.format(m)+' м':formatter.format(m*1000)+' мм'}
function readParameters(){return Object.fromEntries(Object.entries(inputs).map(([key,input])=>[key,input.value.trim()===''?NaN:Number(input.value)]))}
function setParameters(p){for(const [key,input] of Object.entries(inputs)) input.value=p[key];updateGeometry()}
function updateGeometry(){
  const p=readParameters();
  $('circumference-value').textContent=Number.isFinite(p.circumferenceRatio)?p.circumferenceRatio.toFixed(2).replace('.',',')+' λ':'—';
  $('pitch-value').textContent=Number.isFinite(p.pitchDeg)?formatter.format(p.pitchDeg)+'°':'—';
  try{
    const g=calculateGeometry(p);lastValidParameters={...p};
    $('geometry-error').hidden=true;$('export-geometry').disabled=false;
    for(const [id,value] of Object.entries({'wavelength':g.wavelengthM,'diameter':g.diameterM,'circumference':g.circumferenceM,'spacing':g.spacingM,'length':g.axialLengthM,'wire':g.wireLengthM})) $('result-'+id).textContent=formatLength(value);
    const classic=p.circumferenceRatio>=0.8&&p.circumferenceRatio<=1.15&&p.pitchDeg>=12&&p.pitchDeg<=14&&p.turns>=4;
    $('geometry-hint').textContent=classic?'Пропорции находятся внутри одного из классических учебных диапазонов осевого режима. Это ориентир геометрии, а не подтверждение характеристик.':'Геометрия посчитана. По этим размерам калькулятор не устанавливает режим, поляризацию, согласование или усиление.';
    if(classic){const reference=document.createElement('a');reference.href='#source-clark';reference.textContent='Источник диапазона [4]';$('geometry-hint').append(' ',reference)}
    drawTriangle(p.pitchDeg);
    document.querySelectorAll('[data-preset]').forEach(b=>{const active=b.dataset.preset==='axial'&&Object.keys(DEFAULT_PARAMETERS).every(k=>p[k]===DEFAULT_PARAMETERS[k]);b.classList.toggle('active',active);b.setAttribute('aria-pressed',String(active))});
    setStorage('helix-geometry-v1',JSON.stringify(p));
  }catch(error){
    $('geometry-error').textContent=error.message;$('geometry-error').hidden=false;$('export-geometry').disabled=true;
    document.querySelectorAll('#geometry-results strong').forEach(x=>x.textContent='—');
    $('geometry-hint').textContent='Исправьте входные данные. Результаты скрыты, чтобы не показывать предыдущий расчёт как текущий.';
  }
}
function drawTriangle(deg){
  const x=45,y=200,w=300,h=w*Math.tan(deg*Math.PI/180),top=y-h;
  $('triangle-fill').setAttribute('d',`M${x} ${y} L${x+w} ${y} L${x+w} ${top} Z`);
  $('triangle-wire').setAttribute('d',`M${x} ${y} L${x+w} ${top}`);
  document.querySelector('.triangle-dim').setAttribute('d',`M${x} ${y} H${x+w} V${top}`);
  const r=70,endX=x+r*Math.cos(deg*Math.PI/180),endY=y-r*Math.sin(deg*Math.PI/180);
  $('angle-arc').setAttribute('d',`M${x+r} ${y} A${r} ${r} 0 0 0 ${endX} ${endY}`);
  $('triangle-s-label').setAttribute('x',x+w+13);$('triangle-s-label').setAttribute('y',y-h/2+4);
  $('triangle-alpha-label').setAttribute('x',x+80);$('triangle-alpha-label').setAttribute('y',y-8);
  $('triangle-wire-label').setAttribute('x',120);$('triangle-wire-label').setAttribute('y',y-h*.55-20);
}
function drawHero(){
  const svg=$('helix-hero'),N=8,points=720,parts=[];
  const point=i=>{const t=i/points*N*Math.PI*2;return [240+82*Math.cos(t),355-i/points*264+24*Math.sin(t),Math.sin(t)]};
  for(let i=1;i<=points;i++){const a=point(i-1),b=point(i),v=Math.round(160+(b[2]+1)*39);parts.push(`<path d="M${a[0].toFixed(2)} ${a[1].toFixed(2)} L${b[0].toFixed(2)} ${b[1].toFixed(2)}" fill="none" stroke="rgb(${v-30},${v},${v+2})" stroke-width="4.5" stroke-linecap="round"/>`)}
  svg.innerHTML=`<title id="helix-title">Винтовая антенна над проводящим экраном</title><desc id="helix-desc">Восемь витков вокруг вертикальной оси. Показаны диаметр d, шаг S, экран и точка питания. Это схема, не расчёт поля.</desc><defs><linearGradient id="plate" x1="0" y1="0" x2="0" y2="1"><stop stop-color="#43606b"/><stop offset="1" stop-color="#203d49"/></linearGradient></defs><g opacity=".18" stroke="#afc9d0" stroke-width=".7"><path d="M40 390 H440 M65 414 H415 M90 438 H390 M50 366 H430 M80 342 H400"/><path d="M145 330 L65 442 M195 330 L155 442 M240 330 V442 M285 330 L325 442 M335 330 L415 442"/></g><ellipse cx="240" cy="374" rx="161" ry="47" fill="#081f2b" opacity=".5"/><path d="M75 355 L240 309 L405 355 L240 402Z" fill="url(#plate)" stroke="#67818b" stroke-width="1"/><path d="M240 370 V40" stroke="#79959d" stroke-width="1" stroke-dasharray="4 6"/><path d="M235 48 L240 36 L245 48" fill="none" stroke="#9bb6bd"/><text x="254" y="48" fill="#a8c1c8" font-size="13">ось</text>${parts.join('')}<path d="M322 355 V376" stroke="#e6a06c" stroke-width="5"/><circle cx="322" cy="355" r="5" fill="#e6a06c"/><path d="M324 372 H370 L391 392" fill="none" stroke="#c88c61"/><text x="326" y="414" fill="#e6b58d" font-size="13">питание</text><path d="M158 216 H322 M158 210 V222 M322 210 V222" fill="none" stroke="#7bbeb3" stroke-width="1"/><text x="233" y="207" fill="#a8e3d6" font-size="15">d</text><path d="M345 91 H354 V124 H345" fill="none" stroke="#a8c1c8" stroke-width="1"/><text x="365" y="112" fill="#a8c1c8" font-size="15">S</text><text x="65" y="63" fill="#b9d0d6" font-size="12" letter-spacing="1.5">N = 8 ВИТКОВ</text><text x="83" y="395" fill="#a8c1c8" font-size="13">экран</text>`;
}

for(const input of Object.values(inputs))input.addEventListener('input',updateGeometry);
$('geometry-form').addEventListener('submit',e=>e.preventDefault());
document.querySelectorAll('[data-preset]').forEach(button=>button.addEventListener('click',()=>{
  setParameters(button.dataset.preset==='axial'?{...DEFAULT_PARAMETERS}:{frequencyMHz:100,turns:6,circumferenceRatio:0.1,pitchDeg:5});
  document.querySelectorAll('[data-preset]').forEach(b=>{const active=b===button;b.classList.toggle('active',active);b.setAttribute('aria-pressed',String(active))});
}));
$('reset-geometry').addEventListener('click',()=>{setParameters({...DEFAULT_PARAMETERS});showToast('Исходные параметры восстановлены')});
$('export-geometry').addEventListener('click',()=>{
  const data=createCalculationExport(lastValidParameters);
  const blob=new Blob([JSON.stringify(data,null,2)],{type:'application/json;charset=utf-8'});
  const url=URL.createObjectURL(blob),anchor=document.createElement('a');anchor.href=url;anchor.download=`helix-${lastValidParameters.frequencyMHz}MHz-N${lastValidParameters.turns}.json`;anchor.click();setTimeout(()=>URL.revokeObjectURL(url),1000);showToast('Расчёт сохранён в JSON');
});

const savedTheme=getStorage('helix-theme');
function setTheme(theme){document.documentElement.dataset.theme=theme;$('theme-toggle').textContent=theme==='dark'?'Светлая тема':'Тёмная тема';$('theme-toggle').setAttribute('aria-label',theme==='dark'?'Включить светлую тему':'Включить тёмную тему')}
setTheme(savedTheme||'light');
$('theme-toggle').addEventListener('click',()=>{const theme=document.documentElement.dataset.theme==='dark'?'light':'dark';setTheme(theme);setStorage('helix-theme',theme)});
const savedSize=getStorage('helix-text-size')||'standard';$('text-size').value=savedSize;document.documentElement.dataset.textSize=savedSize;
$('text-size').addEventListener('change',()=>{document.documentElement.dataset.textSize=$('text-size').value;setStorage('helix-text-size',$('text-size').value)});
$('print-button').addEventListener('click',()=>window.print());
$('menu-toggle').addEventListener('click',()=>{const open=$('sidebar').classList.toggle('open');$('menu-toggle').setAttribute('aria-expanded',String(open))});
document.querySelectorAll('#toc a').forEach(link=>link.addEventListener('click',()=>{if(innerWidth<=760){$('sidebar').classList.remove('open');$('menu-toggle').setAttribute('aria-expanded','false')}}));

const sections=[...document.querySelectorAll('section[data-title]')];
const normalize=text=>text.toLowerCase().replace(/ё/g,'е');
$('search').addEventListener('input',()=>{
  const query=normalize($('search').value.trim()),box=$('search-results');box.replaceChildren();
  if(!query){box.hidden=true;return}box.hidden=false;
  const matches=sections.filter(section=>normalize(section.textContent+' '+section.dataset.title).includes(query));
  const count=document.createElement('p');count.textContent=matches.length?`Найдено разделов: ${matches.length}`:'Совпадений нет';box.append(count);
  for(const section of matches){const a=document.createElement('a');a.href='#'+section.id;a.textContent=section.dataset.title;a.addEventListener('click',()=>{if(innerWidth<=760){$('sidebar').classList.remove('open');$('menu-toggle').setAttribute('aria-expanded','false')}});box.append(a)}
});
let scrollTick=false;
function highlightCurrent(){const edge=140;let current=sections[0];for(const s of sections){if(s.getBoundingClientRect().top<=edge)current=s}for(const a of document.querySelectorAll('#toc a')){const active=a.hash==='#'+current.id;a.classList.toggle('active',active);if(active)a.setAttribute('aria-current','location');else a.removeAttribute('aria-current')}scrollTick=false}
window.addEventListener('scroll',()=>{if(!scrollTick){scrollTick=true;requestAnimationFrame(highlightCurrent)}},{passive:true});

async function loadSources(){
  try{
    const response=await fetch('./sources.json');if(!response.ok)throw Error('sources');const data=await response.json();const list=$('source-list');list.replaceChildren();
    for(const item of data.sources){
      const article=document.createElement('article');article.className='source-card';article.id=item.id;
      const top=document.createElement('div');top.className='source-top';const num=document.createElement('span');num.className='source-number';num.textContent='['+item.number+']';const type=document.createElement('span');type.className='source-kind';type.textContent=item.kind;top.append(num,type);
      const title=document.createElement('h3');title.textContent=item.title;
      const author=document.createElement('p');author.textContent=item.author+(item.year?' · '+item.year:'');
      const note=document.createElement('p');note.textContent=item.use;
      const access=document.createElement('p');access.className='source-access';access.textContent=item.access;
      const links=document.createElement('div');links.className='source-links';const a=document.createElement('a');a.href=item.url;a.target='_blank';a.rel='noopener noreferrer';a.textContent='Открыть источник';links.append(a);
      if(item.secondaryUrl){const b=document.createElement('a');b.href=item.secondaryUrl;b.target='_blank';b.rel='noopener noreferrer';b.textContent='Доступный текст';links.append(b)}
      article.append(top,title,author,note,access,links);list.append(article);
    }
  }catch{$('source-list').textContent='Не удалось загрузить библиографию. Реестр доступен по ссылке «Скачать реестр источников» ниже.'}
}
drawHero();
let initial={...DEFAULT_PARAMETERS};try{const saved=JSON.parse(getStorage('helix-geometry-v1'));if(saved){calculateGeometry(saved);initial=saved}}catch{}
setParameters(initial);highlightCurrent();loadSources();
