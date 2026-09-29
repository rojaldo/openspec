import { useCallback, useEffect, useState, type FormEvent } from "react";
import { Link, useParams } from "react-router-dom";

import {
  ApiError,
  assignCapability,
  getEmployee,
  listCapabilities,
  unassignCapability,
  updateAssignmentLevel,
  type Capability,
  type EmployeeDetail,
} from "../api/client";
import { Button } from "../components/Button";
import { Field } from "../components/Field";
import { LevelMeter } from "../components/LevelMeter";
import { PageHeader } from "../components/PageHeader";
import { TableSkeleton } from "../components/TableSkeleton";
import { useToast } from "../components/Toast";

const LEVELS = [1, 2, 3, 4, 5];

export function EmployeeDetailPage() {
  const { id } = useParams<{ id: string }>();
  const employeeId = Number(id);
  const { notify } = useToast();

  const [employee, setEmployee] = useState<EmployeeDetail | null>(null);
  const [capabilities, setCapabilities] = useState<Capability[]>([]);
  const [capabilityId, setCapabilityId] = useState("");
  const [level, setLevel] = useState("1");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [fieldError, setFieldError] = useState<string | undefined>();
  const [busy, setBusy] = useState(false);
  const [editingLevel, setEditingLevel] = useState<number | null>(null);
  const [draftLevel, setDraftLevel] = useState("1");
  const [levelError, setLevelError] = useState<string | undefined>();
  const [pendingUnassign, setPendingUnassign] = useState<number | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [detail, catalog] = await Promise.all([
        getEmployee(employeeId),
        listCapabilities(),
      ]);
      setEmployee(detail);
      setCapabilities(catalog);
      setCapabilityId(catalog.length > 0 ? String(catalog[0].id) : "");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "No se pudo cargar la ficha.");
    } finally {
      setLoading(false);
    }
  }, [employeeId]);

  useEffect(() => {
    void load();
  }, [load]);

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setFieldError(undefined);
    if (!capabilityId) {
      setFieldError("Selecciona una capacidad.");
      return;
    }
    setBusy(true);
    try {
      await assignCapability(employeeId, Number(capabilityId), Number(level));
      notify("Capacidad asignada");
      await load();
    } catch (err) {
      const message = err instanceof ApiError ? err.message : "No se pudo asignar.";
      setFieldError(message);
      notify(message, "error");
    } finally {
      setBusy(false);
    }
  }

  function startLevelEdit(capabilityIdValue: number, current: number) {
    setEditingLevel(capabilityIdValue);
    setDraftLevel(String(current));
    setLevelError(undefined);
  }

  async function onConfirmLevel(capabilityIdValue: number) {
    setLevelError(undefined);
    try {
      await updateAssignmentLevel(employeeId, capabilityIdValue, Number(draftLevel));
      setEditingLevel(null);
      notify("Nivel actualizado");
      await load();
    } catch (err) {
      const message = err instanceof ApiError ? err.message : "No se pudo actualizar.";
      setLevelError(message);
      notify(message, "error");
    }
  }

  async function onConfirmUnassign(capabilityIdValue: number) {
    setPendingUnassign(null);
    try {
      await unassignCapability(employeeId, capabilityIdValue);
      notify("Capacidad desasignada");
      await load();
    } catch (err) {
      notify(err instanceof ApiError ? err.message : "No se pudo desasignar.", "error");
    }
  }

  if (loading) {
    return (
      <>
        <PageHeader title="Ficha de empleado" />
        <TableSkeleton rows={2} />
      </>
    );
  }
  if (error || !employee) {
    return (
      <>
        <PageHeader title="Ficha de empleado" />
        <div className="alert alert--error" role="alert">
          <div className="alert__body">{error ?? "El empleado no existe."}</div>
          <Button size="sm" type="button" onClick={() => void load()}>
            Reintentar
          </Button>
        </div>
      </>
    );
  }

  return (
    <>
      <PageHeader
        title={employee.name}
        actions={
          <Link className="btn" to="/empleados">
            Volver a empleados
          </Link>
        }
      />

      {capabilities.length === 0 ? (
        <div className="alert alert--error" role="alert">
          <div className="alert__body">
            El catálogo está vacío: crea primero una capacidad para poder asignarla.
          </div>
        </div>
      ) : (
        <form className="card" onSubmit={onSubmit} noValidate>
          <div className="form-row">
            <Field
              label="Capacidad"
              htmlFor="assignment-capability"
              error={fieldError}
              width="wide"
            >
              <select
                id="assignment-capability"
                value={capabilityId}
                onChange={(event) => setCapabilityId(event.target.value)}
              >
                {capabilities.map((capability) => (
                  <option key={capability.id} value={capability.id}>
                    {capability.name}
                  </option>
                ))}
              </select>
            </Field>
            <Field label="Nivel" htmlFor="assignment-level" width="narrow">
              <select
                id="assignment-level"
                value={level}
                onChange={(event) => setLevel(event.target.value)}
              >
                {LEVELS.map((value) => (
                  <option key={value} value={value}>
                    {value}
                  </option>
                ))}
              </select>
            </Field>
            <Button type="submit" variant="primary" disabled={busy}>
              Asignar
            </Button>
          </div>
        </form>
      )}

      {employee.capabilities.length === 0 ? (
        <div className="table-surface">
          <table className="table">
            <caption className="visually-hidden">
              Capacidades asignadas a {employee.name}
            </caption>
            <thead>
              <tr>
                <th scope="col">Capacidad</th>
                <th scope="col">Nivel</th>
                <th scope="col" className="cell--actions">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td colSpan={3} className="state">
                  Este empleado no tiene capacidades asignadas.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      ) : (
        <div className="table-surface">
          <table className="table">
            <caption className="visually-hidden">
              Capacidades asignadas a {employee.name}
            </caption>
            <thead>
              <tr>
                <th scope="col">Capacidad</th>
                <th scope="col">Nivel</th>
                <th scope="col" className="cell--actions">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody>
              {employee.capabilities.map((assignment) => (
                <tr key={assignment.capability_id}>
                  <td>{assignment.name}</td>
                  <td>
                    {editingLevel === assignment.capability_id ? (
                      <span className="inline-edit">
                        <select
                          className="inline-edit__input"
                          value={draftLevel}
                          onChange={(event) => setDraftLevel(event.target.value)}
                          aria-label={`Nuevo nivel para ${assignment.name}`}
                        >
                          {LEVELS.map((value) => (
                            <option key={value} value={value}>
                              {value}
                            </option>
                          ))}
                        </select>
                        {levelError ? (
                          <span className="error" role="alert">
                            {levelError}
                          </span>
                        ) : null}
                      </span>
                    ) : (
                      <LevelMeter level={assignment.level} />
                    )}
                  </td>
                  <td className="cell--actions">
                    {editingLevel === assignment.capability_id ? (
                      <span className="confirm">
                        <Button
                          size="sm"
                          variant="primary"
                          type="button"
                          onClick={() => void onConfirmLevel(assignment.capability_id)}
                        >
                          Guardar
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          type="button"
                          onClick={() => setEditingLevel(null)}
                        >
                          Cancelar
                        </Button>
                      </span>
                    ) : pendingUnassign === assignment.capability_id ? (
                      <span className="confirm">
                        <span className="confirm__text">¿Quitar?</span>
                        <Button
                          size="sm"
                          variant="danger"
                          type="button"
                          onClick={() => void onConfirmUnassign(assignment.capability_id)}
                        >
                          Sí, quitar
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          type="button"
                          onClick={() => setPendingUnassign(null)}
                        >
                          Cancelar
                        </Button>
                      </span>
                    ) : (
                      <span className="confirm">
                        <Button
                          size="sm"
                          type="button"
                          onClick={() =>
                            startLevelEdit(assignment.capability_id, assignment.level)
                          }
                          aria-label={`Cambiar nivel de ${assignment.name}`}
                        >
                          Cambiar nivel
                        </Button>
                        <Button
                          size="sm"
                          variant="danger"
                          type="button"
                          onClick={() => setPendingUnassign(assignment.capability_id)}
                          aria-label={`Quitar ${assignment.name}`}
                        >
                          Quitar
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
