import { useEffect, useState, type FormEvent } from "react";

import {
  ApiError,
  listCapabilities,
  searchEmployees,
  type Capability,
  type SearchResult,
} from "../api/client";
import { Button } from "../components/Button";
import { EmptyState } from "../components/EmptyState";
import { Field } from "../components/Field";
import { LevelMeter } from "../components/LevelMeter";
import { PageHeader } from "../components/PageHeader";
import { Table } from "../components/Table";
import { TableSkeleton } from "../components/TableSkeleton";

export function SearchPage() {
  const [capabilities, setCapabilities] = useState<Capability[]>([]);
  const [capabilityId, setCapabilityId] = useState("");
  const [minLevel, setMinLevel] = useState("");
  const [results, setResults] = useState<SearchResult[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    async function loadCatalog() {
      try {
        const catalog = await listCapabilities();
        setCapabilities(catalog);
        setCapabilityId(catalog.length > 0 ? String(catalog[0].id) : "");
      } catch (err) {
        setError(err instanceof ApiError ? err.message : "No se pudo cargar el catálogo.");
      } finally {
        setLoading(false);
      }
    }
    void loadCatalog();
  }, []);

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    if (!capabilityId) {
      setError("Selecciona una capacidad para buscar.");
      return;
    }
    setBusy(true);
    setError(null);
    try {
      const min = minLevel.trim() === "" ? null : Number(minLevel);
      setResults(await searchEmployees(Number(capabilityId), min));
    } catch (err) {
      setResults(null);
      setError(err instanceof ApiError ? err.message : "No se pudo completar la búsqueda.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <>
      <PageHeader title="Buscador" />

      <form className="card" onSubmit={onSubmit} noValidate>
        <div className="form-row">
          <Field label="Capacidad" htmlFor="search-capability" width="wide">
            <select
              id="search-capability"
              value={capabilityId}
              onChange={(event) => setCapabilityId(event.target.value)}
              disabled={loading || capabilities.length === 0}
            >
              {capabilities.map((capability) => (
                <option key={capability.id} value={capability.id}>
                  {capability.name}
                </option>
              ))}
            </select>
          </Field>
          <Field
            label="Nivel mínimo"
            htmlFor="search-min-level"
            width="narrow"
            hint="Vacío: cualquier nivel."
          >
            <input
              id="search-min-level"
              type="number"
              min={1}
              max={5}
              value={minLevel}
              onChange={(event) => setMinLevel(event.target.value)}
            />
          </Field>
          <Button type="submit" variant="primary" disabled={busy}>
            Buscar
          </Button>
        </div>
      </form>

      {loading ? (
        <TableSkeleton rows={3} />
      ) : capabilities.length === 0 ? (
        <EmptyState
          title="No hay capacidades para buscar"
          text="Crea al menos una capacidad en el catálogo antes de usar el buscador."
        />
      ) : error ? (
        <div className="alert alert--error" role="alert">
          <div className="alert__body">{error}</div>
        </div>
      ) : results === null ? (
        <EmptyState
          title="Elige un criterio"
          text="Selecciona una capacidad y, si quieres, un nivel mínimo para acotar los resultados."
        />
      ) : results.length === 0 ? (
        <EmptyState
          title="Sin resultados"
          text="Ningún empleado cumple ese criterio. Prueba bajando el nivel mínimo."
        />
      ) : (
        <Table
          caption="Resultados de la búsqueda"
          headers={["Empleado", "Nivel"]}
          rows={results.map((result) => [
            { content: result.name },
            { content: <LevelMeter level={result.level} /> },
          ])}
        />
      )}
    </>
  );
}
