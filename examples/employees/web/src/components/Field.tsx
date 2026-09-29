import type { ReactNode } from "react";

type Width = "narrow" | "default" | "wide";

interface FieldProps {
  label: string;
  htmlFor: string;
  hint?: string;
  error?: string;
  width?: Width;
  children: ReactNode;
}

const widthClass: Record<Width, string> = {
  narrow: "field--narrow",
  default: "field--default",
  wide: "",
};

export function Field({
  label,
  htmlFor,
  hint,
  error,
  width = "default",
  children,
}: FieldProps) {
  return (
    <div className={`field ${widthClass[width]}${error ? " field--error" : ""}`}>
      <label htmlFor={htmlFor}>{label}</label>
      {children}
      {error ? (
        <span className="error" role="alert">
          {error}
        </span>
      ) : (
        <span className="hint">{hint ?? "\u00a0"}</span>
      )}
    </div>
  );
}
