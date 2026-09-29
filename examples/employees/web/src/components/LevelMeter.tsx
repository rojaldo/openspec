interface LevelMeterProps {
  level: number;
  max?: number;
}

export function LevelMeter({ level, max = 5 }: LevelMeterProps) {
  const bars = Array.from({ length: max }, (_, index) => index < level);
  return (
    <span className="level-meter" role="img" aria-label={`Nivel ${level} de ${max}`}>
      <span className="level-meter__bars" aria-hidden="true">
        {bars.map((on, index) => (
          <span
            key={index}
            className={`level-meter__bar${on ? " level-meter__bar--on" : ""}`}
          />
        ))}
      </span>
      <span className="level-meter__value" aria-hidden="true">
        {level}
      </span>
    </span>
  );
}
