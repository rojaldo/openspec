import { Link, type To } from "react-router-dom";

import { ChevronRight } from "./icons";

interface RowLinkProps {
  to: To;
  label: string;
  description?: string;
}

export function RowLink({ to, label, description }: RowLinkProps) {
  return (
    <tr className="row-link">
      <td>
        <Link className="row-link__anchor" to={to}>
          {label}
        </Link>
        {description ? (
          <p className="row-link__meta">{description}</p>
        ) : null}
      </td>
      <td className="cell--actions">
        <ChevronRight className="row-link__chevron" />
      </td>
    </tr>
  );
}
