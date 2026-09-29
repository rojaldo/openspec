import { useEffect, useRef } from "react";
import type { ReactNode, Ref } from "react";
import { Outlet, Route, Routes, useLocation } from "react-router-dom";

import { AuthProvider, RequireAuth } from "./components/Auth";
import { Nav } from "./components/Nav";
import { ToastProvider } from "./components/Toast";
import { CapabilitiesPage } from "./pages/CapabilitiesPage";
import { EmployeeDetailPage } from "./pages/EmployeeDetailPage";
import { EmployeesPage } from "./pages/EmployeesPage";
import { HomePage } from "./pages/HomePage";
import { LoginPage } from "./pages/LoginPage";
import { SearchPage } from "./pages/SearchPage";

interface ShellProps {
  children: ReactNode;
  withNav?: boolean;
  mainRef?: Ref<HTMLElement>;
}

// El armazon provee contenedor, salto al contenido y su destino (#main), que
// debe existir en toda pantalla; `withNav` distingue el armazon publico del
// autenticado, porque la navegacion solo tiene sentido con sesion.
function Shell({ children, withNav = false, mainRef }: ShellProps) {
  return (
    <>
      <a className="skip-link" href="#main">
        Saltar al contenido
      </a>
      <div className="app-shell">
        {withNav ? <Nav /> : null}
        <main
          id="main"
          ref={mainRef}
          className="app-main"
          tabIndex={-1}
          aria-live="polite"
          aria-atomic="true"
        >
          {children}
        </main>
      </div>
    </>
  );
}

function AuthenticatedShell() {
  const { pathname } = useLocation();
  const mainRef = useRef<HTMLElement>(null);

  useEffect(() => {
    mainRef.current?.focus();
  }, [pathname]);

  return (
    <Shell withNav mainRef={mainRef}>
      <Outlet />
    </Shell>
  );
}

export function App() {
  return (
    <AuthProvider>
      <ToastProvider>
        <Routes>
          <Route
            path="/login"
            element={
              <Shell>
                <LoginPage />
              </Shell>
            }
          />
          <Route
            element={
              <RequireAuth>
                <AuthenticatedShell />
              </RequireAuth>
            }
          >
            <Route path="/" element={<HomePage />} />
            <Route path="/capacidades" element={<CapabilitiesPage />} />
            <Route path="/empleados" element={<EmployeesPage />} />
            <Route path="/empleados/:id" element={<EmployeeDetailPage />} />
            <Route path="/buscar" element={<SearchPage />} />
          </Route>
        </Routes>
      </ToastProvider>
    </AuthProvider>
  );
}
