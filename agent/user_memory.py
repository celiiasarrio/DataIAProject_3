from __future__ import annotations

import re
import time
import unicodedata
from typing import Any, Optional


TOPIC_PATTERNS = {
    "asistencia": ("asistencia",),
    "notas": ("nota", "notas", "calificacion", "calificaciones"),
    "calendario": ("calendario", "evento", "eventos"),
    "tutorias": ("tutoria", "tutorias", "tutoring"),
    "correos": ("correo", "correos", "email", "emails", "mail"),
    "notificaciones": ("notificacion", "notificaciones", "aviso", "avisos"),
    "perfil": ("perfil", "datos personales"),
    "reservas": ("reserva", "reservas"),
}

SHORT_STYLE_PATTERN = re.compile(
    r"\b(?:prefiero|quiero|responde|contestame|contesta|dame)\b.*\b(?:breve|breves|corta|cortas|concisa|concisas|resumen)\b"
)
DETAILED_STYLE_PATTERN = re.compile(
    r"\b(?:prefiero|quiero|responde|contestame|contesta|explica|dame)\b.*\b(?:detallada|detalladas|larga|largas|amplia|amplias)\b"
)
PREFERRED_NAME_PATTERN = re.compile(
    r"\b(?:ll[aá]mame|puedes llamarme|quiero que me llames)\s+([a-záéíóúüñ][a-záéíóúüñ' -]{0,39})",
    re.IGNORECASE,
)
PREFERENCE_FACT_PREFIXES = (
    "Prefiere que le llamen ",
    "Prefiere hablar en español.",
    "Prefiere hablar en inglés.",
    "Prefiere respuestas breves.",
    "Prefiere respuestas más detalladas.",
)


def _normalize_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value or "")
    return "".join(char for char in normalized if not unicodedata.combining(char)).lower()


def _clean_text(value: Any, *, limit: int = 180) -> str:
    text = " ".join(str(value or "").split())
    return text[:limit].strip()


def _merge_unique(existing: list[str], new_items: list[str], *, limit: int) -> list[str]:
    merged: list[str] = []
    seen: set[str] = set()

    for item in [*existing, *new_items]:
        cleaned = _clean_text(item)
        key = cleaned.casefold()
        if not cleaned or key in seen:
            continue
        seen.add(key)
        merged.append(cleaned)

    return merged[-limit:]


def empty_user_memory(user_id: str) -> dict[str, Any]:
    return {
        "user_id": user_id,
        "preferences": {},
        "facts": [],
        "recent_topics": [],
        "conversation_summary": "",
        "updated_at": None,
    }


def normalize_user_memory(memory: Optional[dict[str, Any]], user_id: str) -> dict[str, Any]:
    base = empty_user_memory(user_id)
    if not memory:
        return base

    preferences = memory.get("preferences") or {}
    cleaned_preferences: dict[str, str] = {}
    for key, value in preferences.items():
        cleaned_key = _clean_text(key, limit=40)
        cleaned_value = _clean_text(value, limit=80)
        if cleaned_key and cleaned_value:
            cleaned_preferences[cleaned_key] = cleaned_value

    base["preferences"] = cleaned_preferences
    base["facts"] = _merge_unique(list(memory.get("facts") or []), [], limit=6)
    base["recent_topics"] = _merge_unique(list(memory.get("recent_topics") or []), [], limit=5)
    base["conversation_summary"] = _clean_text(memory.get("conversation_summary") or "", limit=280)
    base["updated_at"] = memory.get("updated_at")
    return base


def build_user_memory_summary(memory: dict[str, Any]) -> str:
    preferences = memory.get("preferences") or {}
    parts: list[str] = []

    preferred_name = preferences.get("preferred_name")
    if preferred_name:
        parts.append(f"Prefiere que le llamen {preferred_name}.")

    language = preferences.get("language")
    if language == "es":
        parts.append("Prefiere hablar en español.")
    elif language == "en":
        parts.append("Prefiere hablar en inglés.")

    response_style = preferences.get("response_style")
    if response_style == "short":
        parts.append("Prefiere respuestas breves.")
    elif response_style == "detailed":
        parts.append("Prefiere respuestas más detalladas.")

    recent_topics = memory.get("recent_topics") or []
    if recent_topics:
        parts.append("Suele consultar " + ", ".join(recent_topics) + ".")

    facts = memory.get("facts") or []
    parts.extend(fact for fact in facts[:3] if fact not in parts)

    summary = " ".join(parts).strip()
    return summary[:280]


def format_user_memory_for_prompt(memory: Optional[dict[str, Any]]) -> str:
    if not memory:
        return "No hay memoria persistente relevante del usuario."

    preferences = memory.get("preferences") or {}
    facts = memory.get("facts") or []
    recent_topics = memory.get("recent_topics") or []
    summary = _clean_text(memory.get("conversation_summary") or "", limit=280)

    lines: list[str] = []
    if preferences.get("preferred_name"):
        lines.append(f"- Nombre preferido: {preferences['preferred_name']}")
    if preferences.get("language") == "es":
        lines.append("- Idioma preferido: español")
    elif preferences.get("language") == "en":
        lines.append("- Idioma preferido: inglés")
    if preferences.get("response_style") == "short":
        lines.append("- Estilo de respuesta: breve")
    elif preferences.get("response_style") == "detailed":
        lines.append("- Estilo de respuesta: detallado")
    if recent_topics:
        lines.append("- Temas recientes: " + ", ".join(recent_topics))
    if facts:
        lines.append("- Hechos recordados: " + "; ".join(facts[:3]))
    if summary:
        lines.append("- Resumen: " + summary)

    if not lines:
        return "No hay memoria persistente relevante del usuario."
    return "\n".join(lines)


def _extract_topics(message: str) -> list[str]:
    normalized = _normalize_text(message)
    topics: list[str] = []

    for topic, patterns in TOPIC_PATTERNS.items():
        if any(pattern in normalized for pattern in patterns):
            topics.append(topic)

    return topics


def _extract_language(message: str) -> Optional[str]:
    normalized = _normalize_text(message)
    if "en ingles" in normalized or "hablame en ingles" in normalized or "speak english" in normalized:
        return "en"
    if "en espanol" in normalized or "en castellano" in normalized:
        return "es"
    return None


def _extract_response_style(message: str) -> Optional[str]:
    normalized = _normalize_text(message)
    if SHORT_STYLE_PATTERN.search(normalized):
        return "short"
    if DETAILED_STYLE_PATTERN.search(normalized):
        return "detailed"
    return None


def _extract_preferred_name(message: str) -> Optional[str]:
    match = PREFERRED_NAME_PATTERN.search(message or "")
    if not match:
        return None

    candidate = _clean_text(match.group(1), limit=40)
    if not candidate:
        return None
    return candidate.split(" ")[0].capitalize()


def _is_forget_all_request(message: str) -> bool:
    normalized = _normalize_text(message)
    return (
        "borra mi memoria" in normalized
        or "olvida todo" in normalized
        or "elimina mi memoria" in normalized
        or "limpia mi memoria" in normalized
    )


def _apply_forget_commands(memory: dict[str, Any], message: str) -> None:
    normalized = _normalize_text(message)

    if "olvida mi nombre" in normalized or "no me llames asi" in normalized:
        memory["preferences"].pop("preferred_name", None)

    if "olvida mis preferencias" in normalized:
        memory["preferences"] = {}

    if "olvida mis temas" in normalized or "olvida mis consultas" in normalized:
        memory["recent_topics"] = []


def _strip_preference_facts(facts: list[str]) -> list[str]:
    return [
        fact
        for fact in facts
        if not any(fact.startswith(prefix) for prefix in PREFERENCE_FACT_PREFIXES)
    ]


def _build_preference_facts(preferences: dict[str, str]) -> list[str]:
    facts: list[str] = []

    preferred_name = preferences.get("preferred_name")
    if preferred_name:
        facts.append(f"Prefiere que le llamen {preferred_name}.")

    language = preferences.get("language")
    if language == "es":
        facts.append("Prefiere hablar en español.")
    elif language == "en":
        facts.append("Prefiere hablar en inglés.")

    response_style = preferences.get("response_style")
    if response_style == "short":
        facts.append("Prefiere respuestas breves.")
    elif response_style == "detailed":
        facts.append("Prefiere respuestas más detalladas.")

    return facts


def update_user_memory(
    current_memory: Optional[dict[str, Any]],
    *,
    user_id: str,
    message: str,
    reply: str,
) -> dict[str, Any]:
    del reply  # Reservado para heurísticas futuras.

    if _is_forget_all_request(message):
        return empty_user_memory(user_id)

    memory = normalize_user_memory(current_memory, user_id=user_id)
    memory["preferences"] = dict(memory.get("preferences") or {})

    _apply_forget_commands(memory, message)

    preferred_name = _extract_preferred_name(message)
    if preferred_name:
        memory["preferences"]["preferred_name"] = preferred_name

    language = _extract_language(message)
    if language:
        memory["preferences"]["language"] = language

    response_style = _extract_response_style(message)
    if response_style:
        memory["preferences"]["response_style"] = response_style

    generated_facts = _build_preference_facts(memory["preferences"])

    memory["facts"] = _merge_unique(
        _strip_preference_facts(list(memory.get("facts") or [])),
        generated_facts,
        limit=6,
    )
    memory["recent_topics"] = _merge_unique(
        list(memory.get("recent_topics") or []),
        _extract_topics(message),
        limit=5,
    )
    memory["conversation_summary"] = build_user_memory_summary(memory)
    memory["updated_at"] = time.time()
    return normalize_user_memory(memory, user_id=user_id)


class InMemoryUserMemoryStore:
    def __init__(self):
        self._memories: dict[str, dict[str, Any]] = {}

    async def get_user_memory(self, user_id: str) -> dict[str, Any]:
        return normalize_user_memory(self._memories.get(user_id), user_id=user_id)

    async def upsert_user_memory(self, user_id: str, memory: dict[str, Any]) -> dict[str, Any]:
        normalized = normalize_user_memory(memory, user_id=user_id)
        self._memories[user_id] = normalized
        return normalized

    async def delete_user_memory(self, user_id: str) -> dict[str, Any]:
        self._memories.pop(user_id, None)
        return empty_user_memory(user_id)


class FirestoreUserMemoryStore:
    def __init__(
        self,
        *,
        project: str,
        database: str = "(default)",
        collection: str = "user_memories",
    ):
        try:
            from google.cloud import firestore
        except ImportError as exc:  # pragma: no cover - depends on runtime image
            raise RuntimeError(
                "La memoria de usuario en Firestore está configurada pero falta "
                "la dependencia `google-cloud-firestore` en el entorno."
            ) from exc

        client_kwargs: dict[str, Any] = {}
        if project:
            client_kwargs["project"] = project
        if database:
            client_kwargs["database"] = database

        self._client = firestore.Client(**client_kwargs)
        self._collection = collection

    def _doc(self, user_id: str):
        return self._client.collection(self._collection).document(user_id)

    async def get_user_memory(self, user_id: str) -> dict[str, Any]:
        snapshot = self._doc(user_id).get()
        if not snapshot.exists:
            return empty_user_memory(user_id)
        return normalize_user_memory(snapshot.to_dict() or {}, user_id=user_id)

    async def upsert_user_memory(self, user_id: str, memory: dict[str, Any]) -> dict[str, Any]:
        normalized = normalize_user_memory(memory, user_id=user_id)
        self._doc(user_id).set(normalized, merge=True)
        return normalized

    async def delete_user_memory(self, user_id: str) -> dict[str, Any]:
        self._doc(user_id).delete()
        return empty_user_memory(user_id)
