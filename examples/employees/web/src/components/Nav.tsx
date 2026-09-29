import { NavLink } from "react-router-dom";

import { useAuth } from "./Auth";
import { Button } from "./Button";

const links = [
  { to: "/", label: "Inicio", end: true },
  { to: "/capacidades", label: "Catálogo" },
  { to: "/empleados", label: "Empleados" },
  { to: "/buscar", label: "Buscador" },
];

export function Nav() {
  const { user, signOut } = useAuth();

  return (
    <nav className="nav" aria-label="Navegación principal">
      {links.map((link) => (
        <NavLink
          key={link.to}
          to={link.to}
          end={link.end}
          className={({ isActive }) => (isActive ? "active" : undefined)}
        >
          {link.label}
        </NavLink>
      ))}
      {user ? (
        <span className="nav__session">
          <span className="nav__user">{user.username}</span>
          <Button
            size="sm"
            variant="ghost"
            type="button"
            onClick={() => void signOut()}
          >
            Cerrar sesión
          </Button>
        </span>
      ) : null}
    </nav>
  );
}
