import time
import uuid
from typing import Any, Optional

from google.adk.errors.already_exists_error import AlreadyExistsError
from google.adk.events import Event
from google.adk.sessions import Session
from google.adk.sessions.base_session_service import (
    BaseSessionService,
    GetSessionConfig,
    ListSessionsResponse,
)


SENSITIVE_STATE_KEYS = {"jwt"}


class FirestoreSessionService(BaseSessionService):
    """Persist ADK sessions in Firestore."""

    def __init__(
        self,
        *,
        project: str,
        database: str = "(default)",
        root_collection: str = "agent_sessions",
    ):
        try:
            from google.cloud import firestore
        except ImportError as exc:  # pragma: no cover - depends on runtime image
            raise RuntimeError(
                "Firestore está configurado pero falta la dependencia "
                "`google-cloud-firestore` en el entorno."
            ) from exc

        client_kwargs: dict[str, Any] = {}
        if project:
            client_kwargs["project"] = project
        if database:
            client_kwargs["database"] = database

        self._client = firestore.Client(**client_kwargs)
        self._root_collection = root_collection
        self._volatile_state: dict[tuple[str, str, str], dict[str, Any]] = {}

    @staticmethod
    def _sanitize_state(state: Optional[dict[str, Any]]) -> dict[str, Any]:
        if not state:
            return {}
        return {key: value for key, value in state.items() if key not in SENSITIVE_STATE_KEYS}

    def _sessions_collection(self, app_name: str, user_id: str):
        return (
            self._client.collection(self._root_collection)
            .document(app_name)
            .collection("users")
            .document(user_id)
            .collection("sessions")
        )

    def _session_doc(self, app_name: str, user_id: str, session_id: str):
        return self._sessions_collection(app_name, user_id).document(session_id)

    def _events_collection(self, app_name: str, user_id: str, session_id: str):
        return self._session_doc(app_name, user_id, session_id).collection("events")

    def _session_payload(self, session: Session) -> dict[str, Any]:
        return {
            "id": session.id,
            "app_name": session.app_name,
            "user_id": session.user_id,
            "state": self._sanitize_state(session.state),
            "last_update_time": session.last_update_time,
        }

    def set_volatile_state(
        self,
        *,
        app_name: str,
        user_id: str,
        session_id: str,
        state: Optional[dict[str, Any]] = None,
    ) -> None:
        self._volatile_state[(app_name, user_id, session_id)] = dict(state or {})

    def _merge_volatile_state(self, session: Session) -> Session:
        volatile_state = self._volatile_state.get((session.app_name, session.user_id, session.id))
        if volatile_state:
            session.state.update(volatile_state)
        return session

    def _session_from_snapshot(self, snapshot, *, events: Optional[list[Event]] = None) -> Session:
        data = snapshot.to_dict() or {}
        session = Session(
            id=snapshot.id,
            appName=data.get("app_name") or data.get("appName") or "",
            userId=data.get("user_id") or data.get("userId") or "",
            state=self._sanitize_state(data.get("state") or {}),
            events=events or [],
            lastUpdateTime=float(data.get("last_update_time") or data.get("lastUpdateTime") or 0.0),
        )
        return self._merge_volatile_state(session)

    def _load_events(
        self,
        *,
        app_name: str,
        user_id: str,
        session_id: str,
        config: Optional[GetSessionConfig] = None,
    ) -> list[Event]:
        event_snapshots = self._events_collection(app_name, user_id, session_id).order_by("timestamp").stream()
        events: list[Event] = []

        for snapshot in event_snapshots:
            payload = snapshot.to_dict() or {}
            payload.setdefault("id", snapshot.id)
            events.append(Event.model_validate(payload))

        if config:
            if config.num_recent_events:
                events = events[-config.num_recent_events :]
            if config.after_timestamp is not None:
                events = [event for event in events if event.timestamp >= config.after_timestamp]

        return events

    async def create_session(
        self,
        *,
        app_name: str,
        user_id: str,
        state: Optional[dict[str, Any]] = None,
        session_id: Optional[str] = None,
    ) -> Session:
        resolved_session_id = session_id.strip() if session_id and session_id.strip() else str(uuid.uuid4())
        session_ref = self._session_doc(app_name, user_id, resolved_session_id)
        if session_ref.get().exists:
            raise AlreadyExistsError(f"Session with id {resolved_session_id} already exists.")

        session = Session(
            id=resolved_session_id,
            appName=app_name,
            userId=user_id,
            state=dict(state or {}),
            events=[],
            lastUpdateTime=time.time(),
        )
        session_ref.set(self._session_payload(session))
        self.set_volatile_state(
            app_name=app_name,
            user_id=user_id,
            session_id=resolved_session_id,
            state=state,
        )
        return self._merge_volatile_state(session)

    async def get_session(
        self,
        *,
        app_name: str,
        user_id: str,
        session_id: str,
        config: Optional[GetSessionConfig] = None,
    ) -> Optional[Session]:
        session_snapshot = self._session_doc(app_name, user_id, session_id).get()
        if not session_snapshot.exists:
            return None

        events = self._load_events(
            app_name=app_name,
            user_id=user_id,
            session_id=session_id,
            config=config,
        )
        return self._session_from_snapshot(session_snapshot, events=events)

    async def list_sessions(
        self,
        *,
        app_name: str,
        user_id: Optional[str] = None,
    ) -> ListSessionsResponse:
        sessions: list[Session] = []

        if user_id is None:
            snapshots = self._client.collection_group("sessions").where("app_name", "==", app_name).stream()
        else:
            snapshots = self._sessions_collection(app_name, user_id).stream()

        for snapshot in snapshots:
            sessions.append(self._session_from_snapshot(snapshot, events=[]))

        return ListSessionsResponse(sessions=sessions)

    async def delete_session(
        self,
        *,
        app_name: str,
        user_id: str,
        session_id: str,
    ) -> None:
        for event_snapshot in self._events_collection(app_name, user_id, session_id).stream():
            event_snapshot.reference.delete()
        self._session_doc(app_name, user_id, session_id).delete()

    async def append_event(self, session: Session, event: Event) -> Event:
        if event.partial:
            return event

        if not event.id:
            event.id = uuid.uuid4().hex

        await super().append_event(session=session, event=event)
        session.last_update_time = event.timestamp

        self._session_doc(session.app_name, session.user_id, session.id).set(
            self._session_payload(session),
            merge=True,
        )

        event_payload = event.model_dump(mode="json", by_alias=True, exclude_none=True)
        self._events_collection(session.app_name, session.user_id, session.id).document(event.id).set(event_payload)

        return event
