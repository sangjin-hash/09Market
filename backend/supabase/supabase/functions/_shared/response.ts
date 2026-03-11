import { corsHeaders } from "./cors.ts";

export function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
}

export function errorResponse(
  error: string,
  message: string,
  status: number
): Response {
  return jsonResponse({ error, message }, status);
}
