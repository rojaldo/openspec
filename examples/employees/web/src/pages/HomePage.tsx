import { PageHeader } from "../components/PageHeader";
import { RowLink } from "../components/RowLink";

const sections = [
  {
    to: "/capacidades",
    title: "Catálogo de capacidades",
    text: "Alta y baja de las capacidades que se pueden asignar a un empleado.",
  },
  {
    to: "/empleados",
    title: "Empleados",
    text: "Registro de empleados y gestión de sus capacidades por nivel.",
  },
  {
    to: "/buscar",
    title: "Buscador",
    text: "Encuentra empleados por capacidad y nivel mínimo de dominio.",
  },
];

export function HomePage() {
  return (
    <>
      <PageHeader title="Portal de empleados" />
      <p>
        Catálogo de capacidades, nivel de dominio de 1 a 5 por empleado y búsqueda
        por capacidad con nivel mínimo opcional.
      </p>
      <div className="table-surface">
        <table className="table">
          <caption className="visually-hidden">Secciones del portal</caption>
          <tbody>
            {sections.map((section) => (
              <RowLink
                key={section.to}
                to={section.to}
                label={section.title}
                description={section.text}
              />
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
