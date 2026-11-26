export const SPEED_OF_LIGHT = 299792458;
export const DEFAULT_PARAMETERS = Object.freeze({frequencyMHz:1000,turns:8,circumferenceRatio:1,pitchDeg:13});
export function calculateGeometry({frequencyMHz,turns,circumferenceRatio,pitchDeg}) {
  if (!Number.isFinite(frequencyMHz) || frequencyMHz<1 || frequencyMHz>30000) throw new RangeError('Частота должна быть от 1 до 30 000 МГц.');
  if (!Number.isInteger(turns) || turns<1 || turns>30) throw new RangeError('Укажите целое число витков от 1 до 30.');
  if (!Number.isFinite(circumferenceRatio) || circumferenceRatio<0.05 || circumferenceRatio>1.5) throw new RangeError('Отношение C/λ должно быть от 0,05 до 1,50.');
  if (!Number.isFinite(pitchDeg) || pitchDeg<3 || pitchDeg>30) throw new RangeError('Угол подъёма должен быть от 3 до 30°.');
  const wavelengthM=SPEED_OF_LIGHT/(frequencyMHz*1e6);
  const circumferenceM=wavelengthM*circumferenceRatio;
  const diameterM=circumferenceM/Math.PI;
  const spacingM=circumferenceM*Math.tan(pitchDeg*Math.PI/180);
  const axialLengthM=turns*spacingM;
  const wireLengthM=turns*Math.hypot(circumferenceM,spacingM);
  return {wavelengthM,circumferenceM,diameterM,spacingM,axialLengthM,wireLengthM,spacingRatio:spacingM/wavelengthM,pitchDeg,turns};
}
export function createCalculationExport(parameters) {
  return {
    format:'helix-atlas.geometry',version:1,
    model:'Идеальная цилиндрическая винтовая линия в свободном пространстве',
    input:{...parameters},result:calculateGeometry(parameters),
    resultUnits:'Все длины в метрах; углы в градусах; отношения безразмерны',
    speedOfLightMPerS:SPEED_OF_LIGHT,
    equations:['lambda=c/(frequencyMHz*1e6)','C=lambda*circumferenceRatio','d=C/pi','S=C*tan(pitchDeg*pi/180)','L=turns*S','wire=turns*hypot(C,S)'],
    exclusions:['Подвод, согласование и припуск провода не включены','Не учитываются толщина провода, каркас и экран','Нет предсказания КСВ, усиления, поляризации и диаграммы'],
    generatedAt:new Date().toISOString()
  };
}
