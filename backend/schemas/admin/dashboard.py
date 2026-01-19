from pydantic import BaseModel
from typing import List

class DashboardStats(BaseModel):
    total_users: int
    total_couples: int
    active_couples: int
    ended_couples: int
    single_users: int


class MessagesByDay(BaseModel):
    day: str
    total: int


class TopCouple(BaseModel):
    couple_id: int
    total_messages: int


class DashboardResponse(BaseModel):
    stats: DashboardStats
    messages_by_day: List[MessagesByDay]
    top_couples: List[TopCouple]
