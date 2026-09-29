export interface Capability {
  id: number;
  name: string;
}

export interface Employee {
  id: number;
  name: string;
}

export interface Assignment {
  capability_id: number;
  name: string;
  level: number;
}

export interface EmployeeDetail {
  id: number;
  name: string;
  capabilities: Assignment[];
}

export interface SearchResult {
  id: number;
  name: string;
  level: number;
}

export interface User {
  id: number;
  username: string;
  role: string;
}

export class ApiError extends Error {
  status: number;

  constructor(message: string, status: number) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

// Un 401 significa que la sesión ya no vale: el contexto escucha este aviso y
// cierra la sesión, en lugar de dejar la interfaz en un estado mentiroso.
let onUnauthorized: (() => void) | null = null;

export function setUnauthorizedHandler(handler: (() => void) | null): void {
  onUnauthorized = handler;
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`/api${path}`, {
    headers: { "Content-Type": "application/json" },
    ...init,
  });

  if (response.status === 401) {
    onUnauthorized?.();
    throw new ApiError("La sesión ha caducado. Vuelve a acceder.", 401);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  const text = await response.text();
  const payload: unknown = text ? JSON.parse(text) : null;

  if (!response.ok) {
    const message =
      payload && typeof payload === "object" && "error" in payload
        ? String((payload as { error: unknown }).error)
        : `Error ${response.status}`;
    throw new ApiError(message, response.status);
  }

  return payload as T;
}

export function listCapabilities(): Promise<Capability[]> {
  return request<Capability[]>("/capabilities");
}

export function createCapability(name: string): Promise<Capability> {
  return request<Capability>("/capabilities", {
    method: "POST",
    body: JSON.stringify({ name }),
  });
}

export function updateCapability(id: number, name: string): Promise<Capability> {
  return request<Capability>(`/capabilities/${id}`, {
    method: "PUT",
    body: JSON.stringify({ name }),
  });
}

export function deleteCapability(id: number): Promise<void> {
  return request<void>(`/capabilities/${id}`, { method: "DELETE" });
}

export function listEmployees(): Promise<Employee[]> {
  return request<Employee[]>("/employees");
}

export function createEmployee(name: string): Promise<Employee> {
  return request<Employee>("/employees", {
    method: "POST",
    body: JSON.stringify({ name }),
  });
}

export function updateEmployee(id: number, name: string): Promise<Employee> {
  return request<Employee>(`/employees/${id}`, {
    method: "PUT",
    body: JSON.stringify({ name }),
  });
}

export function deleteEmployee(id: number): Promise<void> {
  return request<void>(`/employees/${id}`, { method: "DELETE" });
}

export function getEmployee(id: number): Promise<EmployeeDetail> {
  return request<EmployeeDetail>(`/employees/${id}`);
}

export function assignCapability(
  employeeId: number,
  capabilityId: number,
  level: number,
): Promise<void> {
  return request<void>(`/employees/${employeeId}/capabilities`, {
    method: "POST",
    body: JSON.stringify({ capability_id: capabilityId, level }),
  });
}

export function updateAssignmentLevel(
  employeeId: number,
  capabilityId: number,
  level: number,
): Promise<void> {
  return request<void>(`/employees/${employeeId}/capabilities/${capabilityId}`, {
    method: "PUT",
    body: JSON.stringify({ level }),
  });
}

export function unassignCapability(
  employeeId: number,
  capabilityId: number,
): Promise<void> {
  return request<void>(`/employees/${employeeId}/capabilities/${capabilityId}`, {
    method: "DELETE",
  });
}

export function searchEmployees(
  capabilityId: number,
  minLevel: number | null,
): Promise<SearchResult[]> {
  const params = new URLSearchParams({ capability_id: String(capabilityId) });
  if (minLevel !== null) {
    params.set("min_level", String(minLevel));
  }
  return request<SearchResult[]>(`/search?${params.toString()}`);
}

// --- autenticación --------------------------------------------------------

async function authRequest<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(path, {
    headers: { "Content-Type": "application/json" },
    ...init,
  });

  if (response.status === 204) {
    return undefined as T;
  }

  const text = await response.text();
  const payload: unknown = text ? JSON.parse(text) : null;

  if (!response.ok) {
    const message =
      payload && typeof payload === "object" && "error" in payload
        ? String((payload as { error: unknown }).error)
        : `Error ${response.status}`;
    throw new ApiError(message, response.status);
  }

  return payload as T;
}

export function login(username: string, password: string): Promise<User> {
  return authRequest<User>("/auth/login", {
    method: "POST",
    body: JSON.stringify({ username, password }),
  });
}

export function logout(): Promise<void> {
  return authRequest<void>("/auth/logout", { method: "POST" });
}

export function fetchMe(): Promise<User> {
  return authRequest<User>("/auth/me");
}

export function changePassword(
  currentPassword: string,
  newPassword: string,
): Promise<void> {
  return authRequest<void>("/auth/password", {
    method: "POST",
    body: JSON.stringify({
      current_password: currentPassword,
      new_password: newPassword,
    }),
  });
}
