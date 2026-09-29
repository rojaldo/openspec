import { useCallback, useEffect, useState, type FormEvent } from "react";

import {
  ApiError,
  createCapability,
  deleteCapability,
  listCapabilities,
  updateCapability,
  type Capability,
} from "../api/client";
import { Button } from "../components/Button";
import { EmptyState } from "../components/EmptyState";
import { Field } from "../components/Field";
import { PageHeader } from "../components/PageHeader";
import { Table } from "../components/Table";
import { TableSkeleton } from "../components/TableSkeleton";
import { useToast } from "../components/Toast";

export function CapabilitiesPage() {
  const { notify } = useToast();
  const [items, setItems] = useState<Capability[]>([]);
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
      setItems(await listCapabilities());
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "No se pudo cargar el catálogo.");
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
      setFieldError("El nombre de la capacidad es obligatorio.");
      return;
    }
    setBusy(true);
    try {
      await createCapability(name.trim());
      setName("");
      notify("Capacidad creada");
      await load();
    } catch (err) {
      const message = err instanceof ApiError ? err.message : "No se pudo crear.";
      setFieldError(message);
      notify(message, "error");
    } finally {
      setBusy(false);
    }
  }

  async function onConfirmDelete(capability: Capability) {
    setPendingId(null);
    try {
      await deleteCapability(capability.id);
      notify("Capacidad eliminada");
      await load();
    } catch (err) {
      notify(err instanceof ApiError ? err.message : "No se pudo eliminar.", "error");
    }
  }

  function startEdit(capability: Capability) {
    setEditingId(capability.id);
    setEditName(capability.name);
    setEditError(undefined);
  }

  async function onConfirmEdit(capability: Capability) {
    setEditError(undefined);
    const name = editName.trim();
    if (!name) {
      setEditError("El nombre de la capacidad es obligatorio.");
      return;
    }
    try {
      await updateCapability(capability.id, name);
      setEditingId(null);
      notify("Capacidad actualizada");
      await load();
    } catch (err) {
      const message = err instanceof ApiError ? err.message : "No se pudo actualizar.";
      setEditError(message);
      notify(message, "error");
    }
  }

  return (
    <>
      <PageHeader title="Catálogo de capacidades" />

      <form className="card" onSubmit={onSubmit} noValidate>
        <div className="form-row">
          <Field
            label="Nueva capacidad"
            htmlFor="capability-name"
            error={fieldError}
            hint="El nombre debe ser único en el catálogo."
          >
            <input
              id="capability-name"
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
          title="Todavía no hay capacidades"
          text="Crea la primera capacidad para poder asignarla a los empleados."
        />
      ) : (
        <Table
          caption="Catálogo de capacidades"
          headers={["Capacidad", "Acciones"]}
          rows={items.map((capability) => [
            {
              content:
                editingId === capability.id ? (
                  <span className="inline-edit">
                    <input
                      className="inline-edit__input"
                      value={editName}
                      onChange={(event) => setEditName(event.target.value)}
                      aria-label={`Nuevo nombre para ${capability.name}`}
                    />
                    {editError ? (
                      <span className="error" role="alert">
                        {editError}
                      </span>
                    ) : null}
                  </span>
                ) : (
                  capability.name
                ),
            },
            {
              content:
                editingId === capability.id ? (
                  <span className="confirm">
                    <Button
                      size="sm"
                      variant="primary"
                      type="button"
                      onClick={() => void onConfirmEdit(capability)}
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
                ) : pendingId === capability.id ? (
                  <span className="confirm">
                    <span className="confirm__text">¿Eliminar?</span>
                    <Button
                      size="sm"
                      variant="danger"
                      type="button"
                      onClick={() => void onConfirmDelete(capability)}
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
                      onClick={() => startEdit(capability)}
                      aria-label={`Editar ${capability.name}`}
                    >
                      Editar
                    </Button>
                    <Button
                      size="sm"
                      variant="danger"
                      type="button"
                      onClick={() => setPendingId(capability.id)}
                      aria-label={`Eliminar ${capability.name}`}
                    >
                      Eliminar
                    </Button>
                  </span>
                ),
              align: "end",
            },
          ])}
        />
      )}
    </>
  );
}
