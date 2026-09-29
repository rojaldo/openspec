import type { ReactNode } from "react";

import { Button } from "./Button";

interface EmptyStateProps {
  title: string;
  text: string;
  actionLabel?: string;
  onAction?: () => void;
  children?: ReactNode;
}

export function EmptyState({
  title,
  text,
  actionLabel,
  onAction,
  children,
}: EmptyStateProps) {
  return (
    <div className="empty-state">
      <p className="empty-state__title">{title}</p>
      <p className="empty-state__text">{text}</p>
      {actionLabel && onAction ? (
        <div className="empty-state__action">
          <Button variant="primary" type="button" onClick={onAction}>
            {actionLabel}
          </Button>
        </div>
      ) : null}
      {children}
    </div>
  );
}
