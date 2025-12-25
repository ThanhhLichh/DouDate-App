from typing import Optional
from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):

    APP_NAME: str = "DuoDate API"
    DEBUG: bool = True

    SECRET_KEY: str

    DB_HOST: str = Field(..., env="DB_HOST")
    DB_PORT: int = Field(3306, env="DB_PORT")
    DB_USER: str = Field(..., env="DB_USER")
    DB_PASSWORD: Optional[str] = Field(None, env="DB_PASSWORD")
    DB_NAME: str = Field(..., env="DB_NAME")

    @property
    def DATABASE_URL(self) -> str:
        password = self.DB_PASSWORD or ""
        return (
            f"mysql+pymysql://{self.DB_USER}:"
            f"{password}@{self.DB_HOST}:"
            f"{self.DB_PORT}/{self.DB_NAME}"
        )

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
