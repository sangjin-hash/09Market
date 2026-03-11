export function requireFields(
  body: Record<string, unknown>,
  fields: string[]
): void {
  for (const field of fields) {
    if (
      body[field] === undefined ||
      body[field] === null ||
      body[field] === ""
    ) {
      throw {
        error: "missing_required_field",
        message: `'${field}' is required`,
        field,
        status: 400,
      };
    }
  }
}

export function parseIntParam(
  url: URL,
  name: string,
  defaultValue: number
): number {
  const raw = url.searchParams.get(name);
  if (!raw) return defaultValue;
  const parsed = parseInt(raw, 10);
  return isNaN(parsed) ? defaultValue : parsed;
}
