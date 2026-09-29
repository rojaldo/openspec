import type { ButtonHTMLAttributes } from "react";

type Variant = "default" | "primary" | "danger" | "ghost";
type Size = "default" | "sm";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
}

const variantClass: Record<Variant, string> = {
  default: "",
  primary: " btn--primary",
  danger: " btn--danger",
  ghost: " btn--ghost",
};

export function Button({
  variant = "default",
  size = "default",
  className,
  ...rest
}: ButtonProps) {
  const classes = [
    "btn",
    variantClass[variant],
    size === "sm" ? " btn--sm" : "",
    className ? ` ${className}` : "",
  ].join("");
  return <button className={classes} {...rest} />;
}
