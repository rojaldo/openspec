import type { ReactNode } from "react";

export interface Cell {
  content: ReactNode;
  align?: "start" | "end";
}

interface TableProps {
  caption: string;
  headers: string[];
  rows: Cell[][];
}

export function Table({ caption, headers, rows }: TableProps) {
  return (
    <div className="table-surface">
      <table className="table">
        <caption className="visually-hidden">{caption}</caption>
        <thead>
          <tr>
            {headers.map((header) => (
              <th key={header} scope="col">
                {header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, rowIndex) => (
            <tr key={rowIndex}>
              {row.map((cell, cellIndex) => (
                <td
                  key={cellIndex}
                  className={cell.align === "end" ? "cell--actions" : undefined}
                >
                  {cell.content}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
