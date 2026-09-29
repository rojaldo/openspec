interface TableSkeletonProps {
  rows?: number;
}

export function TableSkeleton({ rows = 3 }: TableSkeletonProps) {
  return (
    <div className="skeleton" aria-hidden="true">
      {Array.from({ length: rows }, (_, index) => (
        <div key={index} className="skeleton__row" />
      ))}
    </div>
  );
}
