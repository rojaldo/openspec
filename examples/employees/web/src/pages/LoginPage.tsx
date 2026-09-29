import { useState, type FormEvent } from "react";
import { Navigate, useLocation } from "react-router-dom";

import { ApiError } from "../api/client";
import { useAuth } from "../components/Auth";
import { Button } from "../components/Button";
import { Field } from "../components/Field";

export function LoginPage() {
  const { user, ready, signIn } = useAuth();
  const location = useLocation();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | undefined>();
  const [busy, setBusy] = useState(false);

  const from = (location.state as { from?: string } | null)?.from ?? "/";

  if (ready && user) {
    return <Navigate to={from} replace />;
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(undefined);
    if (!username.trim() || !password) {
      setError("Usuario y contraseña son obligatorios.");
      return;
    }
    setBusy(true);
    try {
      await signIn(username.trim(), password);
    } catch (err) {
      setError(
        err instanceof ApiError ? err.message : "No se pudo iniciar sesión.",
      );
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="login">
      <div className="login__brand">
        <h1 className="login__title">Portal de empleados</h1>
        <p className="login__text">
          Identifícate para gestionar el catálogo de capacidades y los empleados.
        </p>
      </div>
      <form className="card login__card" onSubmit={onSubmit} noValidate>
        <h2 className="login__card-title">Acceso</h2>
        <Field
          label="Usuario"
          htmlFor="login-username"
          width="wide"
          error={error}
        >
          <input
            id="login-username"
            name="username"
            autoComplete="username"
            value={username}
            onChange={(event) => setUsername(event.target.value)}
          />
        </Field>
        <Field label="Contraseña" htmlFor="login-password" width="wide">
          <input
            id="login-password"
            name="password"
            type="password"
            autoComplete="current-password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
          />
        </Field>
        <Button type="submit" variant="primary" disabled={busy}>
          Acceder
        </Button>
      </form>
    </div>
  );
}
