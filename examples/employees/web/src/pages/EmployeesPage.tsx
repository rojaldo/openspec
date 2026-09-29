import { useCallback, useEffect, useState, type FormEvent } from "react";
import { Link } from "react-router-dom";

import {
  ApiError,
  createEmployee,
  deleteEmployee,
  listEmployees,
  updateEmployee,
  type Employee,
} from "../api/client";
import { Button } from "../components/Button";
import { EmptyState } from "../components/EmptyState";
import { Field } from "../components/Field";
import { PageHeader } from "../components/PageHeader";
import { TableSkeleton } from "../components/TableSkeleton";
import { ChevronRight } from "../components/icons";
import { useToast } from "../components/Toast";

export function EmployeesPage() {
  const { notify } = useToast();
  const [items, setItems] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [name, setName] = useState("");
  const [fieldError, setFieldError] = useState<string | undefined>();
  const [busy, setBusy] = useState(false);
  const [pendingId, setPendingId] = useState<number | null>(null);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editName, setEditName] = useState("");
  const [editError, setEditError] = useState<string | undefined>();

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setItems(await listEmployees());
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "No se pudo cargar la lista.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setFieldError(undefined);
    if (!name.trim()) {
      setFieldError("El nombre del empleado es obligatorio.");
      return;
    }
    setBusy(true);
    try {
      await createEmployee(name.trim());
      setName("");
      notify("Empleado creado");
      await load();
    } catch (err) {
      const message = err instanceof ApiError ? err.message : "No se pudo crear.";
      setFieldError(message);
      notify(message, "error");
    } finally {
      setBusy(false);
    }
  }

  function startEdit(employee: Employee) {
    setEditingId(employee.id);
    setEditName(employee.name);
    setEditError(undefined);
  }

  async function onConfirmEdit(employee: Employee) {
    setEditError(undefined);
    const name = editName.trim();
    if (!name) {
      setEditError("El nombre del empleado es obligatorio.");
      return;
    }
    try {
      await updateEmployee(employee.id, name);
      setEditingId(null);
      notify("Empleado actualizado");
      await load();
    } catch (err) {
      const message = err instanceof ApiError ? err.message : "No se pudo actualizar.";
      setEditError(message);
      notify(message, "error");
    }
  }

  async function onConfirmDelete(employee: Employee) {
    setPendingId(null);
    try {
      await deleteEmployee(employee.id);
      notify("Empleado eliminado");
      await load();
    } catch (err) {
      notify(err instanceof ApiError ? err.message : "No se pudo eliminar.", "error");
    }
  }

  return (
    <>
      <PageHeader title="Empleados" />

      <form className="card" onSubmit={onSubmit} noValidate>
        <div className="form-row">
          <Field
            label="Nuevo empleado"
            htmlFor="employee-name"
            error={fieldError}
            hint="Puede crearse sin ninguna capacidad asignada."
          >
            <input
              id="employee-name"
              value={name}
              onChange={(event) => setName(event.target.value)}
              autoComplete="off"
            />
          </Field>
          <Button type="submit" variant="primary" disabled={busy}>
            Crear
          </Button>
        </div>
      </form>

      {loading ? (
        <TableSkeleton rows={3} />
      ) : error ? (
        <div className="alert alert--error" role="alert">
          <div className="alert__body">{error}</div>
          <Button size="sm" type="button" onClick={() => void load()}>
            Reintentar
          </Button>
        </div>
      ) : items.length === 0 ? (
        <EmptyState
          title="Todavía no hay empleados"
          text="Registra al primer empleado para poder asignarle capacidades."
        />
      ) : (
        <div className="table-surface">
          <table className="table">
            <caption className="visually-hidden">Listado de empleados</caption>
            <thead>
              <tr>
                <th scope="col">Empleado</th>
                <th scope="col">Ver ficha</th>
                <th scope="col" className="cell--actions">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody>
              {items.map((employee) => (
                <tr key={employee.id} className="row-link">
                  <td>
                    {editingId === employee.id ? (
                      <span className="inline-edit">
                        <input
                          className="inline-edit__input"
                          value={editName}
                          onChange={(event) => setEditName(event.target.value)}
                          aria-label={`Nuevo nombre para ${employee.name}`}
                        />
                        {editError ? (
                          <span className="error" role="alert">
                            {editError}
                          </span>
                        ) : null}
                      </span>
                    ) : (
                      <Link
                        className="row-link__anchor"
                        to={`/empleados/${employee.id}`}
                      >
                        {employee.name}
                      </Link>
                    )}
                  </td>
                  <td className="cell--chevron">
                    <ChevronRight className="row-link__chevron" />
                  </td>
                  <td className="cell--actions">
                    {editingId === employee.id ? (
                      <span className="confirm">
                        <Button
                          size="sm"
                          variant="primary"
                          type="button"
                          onClick={() => void onConfirmEdit(employee)}
                        >
                          Guardar
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          type="button"
                          onClick={() => setEditingId(null)}
                        >
                          Cancelar
                        </Button>
                      </span>
                    ) : pendingId === employee.id ? (
                      <span className="confirm">
                        <span className="confirm__text">¿Eliminar?</span>
                        <Button
                          size="sm"
                          variant="danger"
                          type="button"
                          onClick={() => void onConfirmDelete(employee)}
                        >
                          Sí, eliminar
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          type="button"
                          onClick={() => setPendingId(null)}
                        >
                          Cancelar
                        </Button>
                      </span>
                    ) : (
                      <span className="confirm">
                        <Button
                          size="sm"
                          type="button"
                          onClick={() => startEdit(employee)}
                          aria-label={`Editar ${employee.name}`}
                        >
                          Editar
                        </Button>
                        <Button
                          size="sm"
                          variant="danger"
                          type="button"
                          onClick={() => setPendingId(employee.id)}
                          aria-label={`Eliminar ${employee.name}`}
                        >
                          Eliminar
                        </Button>
                      </span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </>
  );
}
